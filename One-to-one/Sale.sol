pragma solidity ^0.4.20;


import 'browser/SafeMath.sol';
import 'browser/WithSaleAgent.sol';
import 'browser/InvestmentsStorage.sol';

/**
*   Контракт агента продажи токенов APLX. Получает токены на свой счёт и продаёт
* их в рамках этапа ICO. Полученные средства незамедлительно переводятся на счёт
* APLEX (multisig родителя InvestmentsStorage) при достижении stagecap
* или в случае невозвратного этапа. В противном случае средства остаются на 
* счету контракта продажи до окночания этапа, после чего разюлокируется механизм 
* возврата средств.
*   Позволяет вносить временные блокировки на операции с токенами 
* в зависимости от адреса счёта.
* 
* Данный контракт является виртуальным и объявляет минимальные 
* требования к контракту агента продажи токенов APLX в рамках ICO.
*/
contract Sale is Ownable, InvestmentsStorage 
{
    using SafeMath for uint;
    
    //Максимально возможное значение баланса на счету
    //Может вводится во избежании ситуации,
    //когда все токены сосредоточены на малом количестве счетов
    //(maxAccountVal = 0, означает отсутствие ограничений)
    uint public maxAccountVal = 0; 
    
    //минимально возможная сумма покупки (Если 0, то без ограничений)
    uint public minBuy = 0;
    
    //показывает количество проданных токенов (вместе с бонусами и служебными)
    uint public sold = 0;
    
    //номер этапа
    uint8 public stagenum = 0;

    //процент токенов переводимый на адрес APLEX (команда)
    uint restrictedPercent;

    //процент токенов переводимый на адрес APLEX (bounty)
    uint bountyPercent;
    
    //процент токенов переводимый на адрес APLEX (резерв)
    uint reservedPercent;

    //адрес APLEX (команда)
    address restricted;
    
    //адрес APLEX (резерв)
    address reserved;
    
    //адрес APLEX (bounty)
    address bounty;
    
    //количество токенов, которые получает агент для продажи
    uint public saleTokenLimit;
    
    //адрес токена для продажи
    WithSaleAgent public token;
    
    //функция покупки токенов (виртуальная)
    function buyTokens() public canBuy payable; 
   
    //функция окончания продажи агентом токенов (виртуальная)
    function finalizeSale() public returns (bool res);
    
    //окончание продажи
    function finalize() public returns (bool res)
    {
        res = finalizeSale();
        
        if (res)
        {
            //вызов в InvestmentsStorage
            super.finalizeStage();
        }
    }
    
    //время начала
    uint public start;
    
    //продолжительность этапа в днях
    uint public period;

    //количество токенов, продаваемых за 1 Ether
    //Внимание! При rate = 1 и покупке 1 APLX за 1 Ether
    //баланс окупателя увеличится на 1 * 10^18, т.к. decimals == 18
    uint public rate;
    
    
    //Здесь устанвливаем только значение времени, сами блокировки можно выставить 
    //только после установки создаваемого агента агентом продажи
    //это сделано в функции buyTokens 
    //
    //время, на которое блокирууются токены на счету restricted
    uint restrictedBlockTime = 183 * 1 days;
        
    //время, на которое блокирууются токены на счету reserved
    uint reservedBlockTime = 1 years;
    
    //показывает время окончания этапа
    function saleEnd() public view returns (uint) { return start.add(period * 1 days); }
    
    //показывает баланс агента
    function myBalance() public view returns (uint) 
    {
        require(token.getAgent() == address(this));
        return token.getAgentBalance(); 
    }
    
    //Расчет максимального количество токенов доступных к покупке,
    //не учитывающий ограничения по максимальному счёту и минимальной покупке.
    //Возвращает max2buy - максимально доступное олачиваемое количество,
    //           maxbonused - получаемое при этом количество с бонусами 
    function Max2BuyTokensTotal() public view returns (uint max2buy, uint maxbonused);
    
    //показывает максимальное количество wei, доступных к оплате
    function Max2SpendWeiTotal() public view returns (uint maxwei)
    {
       uint max2buy = 0;
       (max2buy, ) = Max2BuyTokensTotal();
        maxwei = max2buy.div(rate);
    }
   
    //показывает максимальное количество wei, доступных к оплате
    function Max2SpendWei() public view returns (uint maxwei)
    {
       maxwei = Max2BuyTokens().div(rate);
    }
    
    //показывает максимальное количество токенов, доступных к покупке
    //с учётом ограничений по максимальному счёту иминимальному вложению
    function Max2BuyTokens() public view returns (uint)
    {
       uint rest = 0;
       
      
       
       //проверяем  ограничение на счёт, если такое есть. Если достигнуто,
       //то купить нельзя
       if (maxAccountVal > 0)
       {
           if (maxAccountVal <= token.getBalance(msg.sender))
           {
                return 0;
           }
           rest = maxAccountVal.sub(token.getBalance(msg.sender));
       }
       
       //Если баланс меньше покупки с минимальной суммой вложения,
       //то покупать нельзя
       if (minBuy > 0 && myBalance().div(rate) < minBuy)
       {
          return 0; 
       }
       
       
       
       uint maxbonused = 0;
       uint max2buy = 0;
       
     
       (max2buy, maxbonused) = Max2BuyTokensTotal();
       
       //Если максимально доступная сумма покупки, меньше покупки с минимальной суммой вложения,
       //то покупать нельзя
       if (minBuy > 0 && max2buy.div(rate) < minBuy)
       {
          return 0; 
       }
       
       //Если остаток баланса, позволяет купить меньше, чем 
       //ограничения по максимальному счёту, то возвращаем максимум по балансу
       if (maxbonused < rest)
       {
           return max2buy;
       }
       
       //В противном случае возвращаем максимум 
       //по ограничениям по максимальному счёту
       return rest;
    }
    
    
    //проверяет возможность покупки
    function canIBuy() public view returns (bool res)
    {
        //Условия:
        //- время больше старта
        //- время меньше окончания
        //- агент совпадает с агентом проажи токена
        //- максимальное количество wei, доступных к оплате >= минимально возможного для вложения или оно не установлено
        //- не превышен лимит
        res = now > start && now < saleEnd() &&  token.getAgent() == address(this) && (minBuy == 0 || Max2SpendWei() >= minBuy)  && sold < saleTokenLimit;
    }
    
    
    
    
    //Конструктор
    /* @param _versionSelectorAddress address адрес контракта VersionSelector
     * @param _restrictedAddress address адрес получателя токенов команды
     * @param _reservedAddress address адрес получателя токенов команды (резерв)
     * @param _bountyAddress address адрес получателя токенов для баунти
     * @param _start uint время начала продаж в UNIX формате
     * @param _maxAccountVal uint256 максимально возможное значение баланса на одном счету. 
               (Если 0, то без ограничений)
     * @param _minVal2Buy uint256 минимально возможная сумма вложения в wei.
     *         (Если 0, то без ограничений)
     */
    function Sale(       address _versionSelectorAddress, address _restrictedAddress, address _reservedAddress, address _bountyAddress, uint _start, uint _maxAccountVal, uint _minVal2Buy, uint _stagecap, bool _isRefundable)
             InvestmentsStorage( _versionSelectorAddress,                                                                                                                                        _stagecap,      _isRefundable)  public
    {
        //получаем адрес токена от селектора
        token = WithSaleAgent(selector.curAPLXTokenAddress());//token=new SimpleAPXToken()
        require(address(token) != 0x0);
        
        //адрес APLEX (команда)
        restricted = _restrictedAddress;
        
        //адрес APLEX (bounty)
        bounty = _bountyAddress;
        
        //адрес APLEX (резерв)
        reserved = _reservedAddress;
        
        //время начала  в UNIX формате
        start = _start;
        
        //Возможно, введём ограничение на масмальное количество токенов на счету
        maxAccountVal = _maxAccountVal;
        
        //минимально возможная сумма вложения в Wei
        minBuy = _minVal2Buy;
    }
    
    //fallback функция
    function() external payable 
    {
        require(msg.value >= minBuy);
        buyTokens();
    }

    //модификатор проверки возможности покупки
    modifier canBuy() 
    {
        require(canIBuy());
        _;
    }
        
    //уничтожение контракта с перечислением баланса на счёт владельца
    function killme() public onlyOwner 
    {
        selfdestruct(owner);
    }
}