pragma solidity ^0.4.20;

import 'browser/Ownable.sol';
import 'browser/InvestmentsStorage.sol';
import 'browser/Sale.sol';


/**
*  онтракт агента продажи токенов APLX. ѕолучает токены на свой счЄт и продаЄт
* их в рамках нулевого этапа ICO - PreICO .
* ѕолученные средства незамедлительно перевод€тс€ на счЄт контракта управлени€ 
* инветстици€ми InvestmentsStorage и не могут быть возвращены инвестору. 
*  онтракт InvestmentsStorage, в свою очередь, незамедлительно переводит 
* полученные от этого агента средства счЄт APLEX.
*/
contract PreSale is Sale 
{
    // онструктор
    function PreSale(address _versionSelectorAddress) Sale(_versionSelectorAddress) public 
    {
        //номер этапа
        stagenum=0;
        
        //количество токенов, продаваемых за 1 Ether
        //¬нимание! ѕри rate = 1 и покупке 1 APLX за 1 Ether
        //баланс окупател€ увеличитс€ на 1 * 10^18, т.к. decimals == 18
        rate = 1000;
        
        //врем€ начала
        start = 1517868326;
        
        //продолжительность этапа в дн€х
        period = 30;
        
        //количество токенов, которые получает агент дл€ продажи
        saleTokenLimit = 1000000 * 1 ether;
        //test saleTokenLimit = 2000 * 1 ether;
        
    }
    
    //процент токенов дполнительно получаемых покупателем от количества оплаченных на этапе preICO
    uint presaleBonusPercent=40;
   
    //функци€ окончани€ продажи агентом токенов 
    function finalizeSale() public onlyOwner  returns (bool)
    {
        //≈сли текущее врем€ больше времени окончани€
        if (now > saleEnd())
        {
           //сжигаем остатки
           token.burnAllOfAgent();
           return true;
        }
        
        //≈сли токены кончились (осталось < rate * 10^-18 )
        if (Max2SpendWei()<1) //меньше rate за 1 wei не купишь, такие значени€ могут оставатьс€ после расчета процентов, поэтому их просто сжигаем  (напоминаю 1 токен на счету - это balances[address]==1*10^18)
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
      //¬ычисл€ем количество баланс*100/140%)
       uint max = myBalance().mul(100).div(presaleBonusPercent.add(100));
       //обнул€ем остаток
       max2buy=max.div(rate).mul(rate);
    }
    
     
     //функци€ покупки токенов
    function buyTokens() public canBuy payable  
    {
        //количество оплаченных токенов
        uint tokens = rate.mul(msg.value);
        
        //количество бонусных токенов
        uint bonus;
        bonus = tokens.mul(presaleBonusPercent).div(100);
        
        //всего необходимо перевести 
        uint totaltokens=tokens.add(bonus);
        
        //провер€ем есть ли столько
        require( totaltokens <= myBalance());
          
        //ѕолучаем InvestmentsStorage
        InvestmentsStorage ist = InvestmentsStorage(selector.investmentsStorage());
        //ќтправл€ем средства в investmentsStorage с указанием отправител€ 
        //и номера этапа 
        ist.AddWei.value(msg.value)(msg.sender, stagenum);
        //переводим токены покупателю
        token.transferFromAgent(msg.sender, totaltokens); 
    }   
}