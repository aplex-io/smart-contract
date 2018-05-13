pragma solidity ^0.4.20;


import 'browser/InvestmentsStorage.sol';
import 'browser/Sale.sol';


/**
* Контракт агента продажи токенов APLX. Получает токены на свой счёт и продаёт
* их в рамках нулевого этапа ICO - PreICO .
* Полученные средства незамедлительно переводятся на счёт
* APLEX (multisig родителя InvestmentsStorage) при достижении stagecap.
* В противном случае средства остаются на 
* счету контракта продажи до окночания этапа, после чего разюлокируется механизм 
* возврата средств.
*/
contract PreSale is Sale 
{
    //Конструктор
    /* @param _versionSelectorAddress address адрес контракта VersionSelector
     * @param _start uint время начала продаж в UNIX формате
     * @param _maxAccountVal uint256 максимально возможное значение баланса на одном счету. 
     *         (Если 0, то без ограничений)
     * @param _minVal2Buy uint256 минимально возможная сумма вложения в wei.
     *         (Если 0, то без ограничений)
     */
    constructor(address _versionSelectorAddress,                                     uint _start, uint _maxAccountVal,  uint _minVal2Buy, uint _stagecap, bool _isRefundable) 
               Sale(    _versionSelectorAddress, address(0), address(0), address(0),      _start,      _maxAccountVal,       _minVal2Buy,      _stagecap,      _isRefundable) public
   { 
        
        //количество токенов, продаваемых за 1 Ether
        //Внимание! При rate = 1 и покупке 1 APLX за 1 Ether
        //баланс окупателя увеличится на 1 * 10^18, т.к. decimals == 18
        rate = 1000;
        
        //продолжительность этапа в днях
        period = 10;
        
        //количество токенов, которые получает агент для продажи
        saleTokenLimit = 1000000 * 1 ether;
        
    }
    
    //процент токенов дполнительно получаемых покупателем от количества оплаченных на этапе preICO
    uint presaleBonusPercent = 40;
   
    //функция окончания продажи агентом токенов 
    function finalizeSale() public onlyOwner  returns (bool)
    {
        //Если текущее время больше времени окончания
        if (now > saleEnd())
        {
           //сжигаем остатки
           token.burnAllOfAgent();
           return true;
        }
       
        //Если токены кончились 
        if ( Max2SpendWeiTotal() == 0) 
        {
            //сжигаем остатки
            token.burnAllOfAgent();
            return true;
        }
        return false;
    }
    
    
    //Расчет максимального количество токенов доступных к покупке,
    //не учитывающий ограничения по максимальному счёту и минимальной покупке.
    //Возвращает max2buy - максимально доступное олачиваемое количество,
    //           maxbonused - получаемое при этом количество с бонусами 
    function Max2BuyTokensTotal() public view returns (uint max2buy, uint maxbonused)
    {
      //Вычисляем количество - баланс*100/140%)
       uint max = myBalance().mul(100).div(presaleBonusPercent.add(100));
       
       //обнуляем остаток
       max2buy = max.div(rate).mul(rate);
       
       //вычисляем максимальное значение с бонусами, полученное при 
       //максимальной покупке
       maxbonused = (max2buy * (100 +  presaleBonusPercent)) / 100;
   
    }
    
     
     //функция покупки токенов
    function buyTokens() public canBuy payable  
    {
        //количество оплаченных токенов
        uint tokens = rate.mul(msg.value);
        
        //количество бонусных токенов
        uint bonus;
        bonus = tokens.mul(presaleBonusPercent).div(100);
        
        //всего необходимо перевести 
        uint totaltokens=tokens.add(bonus);
        
        //проверяем есть ли столько
        require( totaltokens <= myBalance());
        
        //проверяем не установлено ли максимальное значение количества токенов на счету,
        //и не превышаем ли мы его покупкой
        require(maxAccountVal==0 || totaltokens.add(token.getBalance(msg.sender)) <= maxAccountVal);
        
        //проверяем не будет ли превышен лимит продаж
        require(sold.add(totaltokens) <= saleTokenLimit);
          
        //Учитываем средства в родительском investmentsStorage с указанием 
        //отправителя 
        super.AddWei(msg.sender);
        
        //переводим токены покупателю
        token.transferFromAgent(msg.sender, totaltokens); 
        
        //добавляем значение в количество проданных токенов
        sold = sold.add(totaltokens);
    }   
}