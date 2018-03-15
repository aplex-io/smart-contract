pragma solidity ^0.4.20;


import 'browser/SafeMath.sol';
import 'browser/WithSaleAgent.sol';


/**
* Контракт агента продажи токенов APLX. Получает токены на свой счёт и продаёт
* их в рамках этапа ICO. Полученные средства незамедлительно переводятся на счёт 
* контракта управления инветстициями InvestmentsStorage. Позволяет вносить
* временные блокировки на операции с токенами в зависимости от адреса счёта.
* 
* Данный контракт является виртуальным и объявляет минимальные 
* требования к контракту агента продажи токенов APLX в рамках ICO.
*/
contract Sale is Ownable, WithVersionSelector 
{
    using SafeMath for uint;
    
    //Максимально возможное значение баланса на счету
    //Может вводится во избежании ситуации,
    //когда все токены сосредоточены на малом количестве счетов
    //(maxAccountVal = 0, означает отсутствие ограничений)
    uint public maxAccountVal = 0; 
    
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
    
    //показывает максимальное количество токенов, доступных к покупке
    function Max2BuyTokens() public view returns (uint max2buy);
   
    //показывает максимальное количество wei, доступных к оплате
    function Max2SpendWei() public view returns (uint maxwei)
    {
       maxwei = Max2BuyTokens().div(rate);
    }
    
    
    //проверяет возможность покупки
    function canIBuy() public view returns (bool res)
    {
        //Условия:
        //- время больше старта
        //- время меньше окончания
        //- агент совпадает с агентом проажи токена
        //- максимальное количество wei, доступных к оплате > 0
        //- известен адрес контракта InvestmentsStorage
        res = now > start && now < saleEnd() &&  token.getAgent() == address(this) && Max2SpendWei()>0 && address(selector.investmentsStorage())!=0;
    }
    
    //показывает количество проданных токенов (вместе с бонусами)
    function sold() public view returns (uint)
    {
        return saleTokenLimit.sub(token.getAgentBalance()); 
    }
    
    //Конструктор
    /* @param _versionSelectorAddress address адрес контракта VersionSelector
     * @param _restrictedAddress address адрес получателя токенов команды
     * @param _reservedAddress address адрес получателя токенов команды (резерв)
     * @param _bountyAddress address адрес получателя токенов для баунти
     * @param _start uint время начала продаж в UNIX формате
     * @param _maxAccountVal uint256 максимально возможное значение баланса на одном счету. 
     *         (Если 0, то без ограничений)
     */
    function Sale(address _versionSelectorAddress, address _restrictedAddress, address _reservedAddress, address _bountyAddress, uint _start, uint _maxAccountVal) WithVersionSelector(_versionSelectorAddress) public
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
    }
    
    //fallback функция
    function() external payable 
    {
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
