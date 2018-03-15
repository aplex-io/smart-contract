pragma solidity ^0.4.20;


import 'browser/InvestmentsStorage.sol';
import 'browser/Sale.sol';


/**
* Контракт агента продажи токенов APLX. Получает токены на свой счёт и продаёт
* их в рамках нулевого этапа ICO - PreICO .
* Полученные средства незамедлительно переводятся на счёт контракта управления 
* инветстициями InvestmentsStorage и не могут быть возвращены инвестору. 
* Контракт InvestmentsStorage, в свою очередь, незамедлительно переводит 
* полученные от этого агента средства счёт APLEX.
*/
contract PreSale is Sale 
{
    //Конструктор
    /* @param _versionSelectorAddress address адрес контракта VersionSelector
     * @param _start uint время начала продаж в UNIX формате
     */
    function  PreSale(address _versionSelectorAddress,                                     uint _start) 
                 Sale(        _versionSelectorAddress, address(0), address(0), address(0),      _start, 0) public
   {
        //номер этапа
        stagenum=0;
        
        //количество токенов, продаваемых за 1 Ether
        //Внимание! При rate = 1 и покупке 1 APLX за 1 Ether
        //баланс окупателя увеличится на 1 * 10^18, т.к. decimals == 18
        rate = 1000;
        
        //продолжительность этапа в днях
        period = 30;
        
        //количество токенов, которые получает агент для продажи
        saleTokenLimit = 1000000 * 1 ether;
    }
    
    //процент токенов дполнительно получаемых покупателем от количества оплаченных на этапе preICO
    uint presaleBonusPercent=40;
   
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
        
        //Если токены кончились (осталось < rate * 10^-18 )
        if (Max2SpendWei()<1) //меньше rate за 1 wei не купишь, такие значения могут оставаться после расчета процентов, поэтому их просто сжигаем  (напоминаю 1 токен на счету - это balances[address]==1*10^18)
        {
            //сжигаем остатки
            token.burnAllOfAgent();
            return true;
        }
        return false;
    }
    
    
     //показывает максимальное количество токенов, доступных к покупке
    function Max2BuyTokens() public view returns (uint max2buy)
    {
      //Вычисляем количество баланс*100/140%)
       uint max = myBalance().mul(100).div(presaleBonusPercent.add(100));
       //обнуляем остаток
       max2buy=max.div(rate).mul(rate);
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
          
        //Получаем InvestmentsStorage
        InvestmentsStorage ist = InvestmentsStorage(selector.investmentsStorage());
        
        //Отправляем средства в investmentsStorage с указанием отправителя 
        //и номера этапа 
        ist.AddWei.value(msg.value)(msg.sender, stagenum);
        
        //переводим токены покупателю
        token.transferFromAgent(msg.sender, totaltokens); 
    }   
}