pragma solidity ^0.4.20;

import 'browser/Ownable.sol';
import 'browser/InvestmentsStorage.sol';
import 'browser/Sale.sol';

/**
* Контракт агента продажи токенов APLX. Получает токены на свой счёт и продаёт
* их в рамках 2-го этапа ICO .
* Полученные средства незамедлительно переводятся на счёт контракта управления 
* инветстициями InvestmentsStorage, где блокируются до достижения софткапа или 
* окончания 2-го этапа ICO.
* 
* - В случае, если софткап достигнут средства переводятся на счёт APLEX
* - В случае если, софткап не достигнут, инвесторы могут вывести свои средства
*   самостоятельно, предварительно сжигая свои токены.
*  
*  Старт этапа: 14 января 2019
* 
*  Период проведения 28 дней
*  
*  Условия бонусов: бонусов нет
*/
contract MainSale2 is Sale {
  
    //Конструктор
    function MainSale2(address _versionSelectorAddress) Sale(_versionSelectorAddress) public
    {
        //Количество токенов для продажи
        stagenum=2;
        
        //Количество токенов для продажи
        saleTokenLimit = 15000000 * 1 ether;
        
        //адрес APLEX (команда)
        restricted = 0x37F51960b8AACdFE323b616768AE18828D8F4eCD;//0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        
        //адрес APLEX (bounty)
        bounty = 0x37F51960b8AACdFE323b616768AE18828D8F4eCD;//0x583031D1113aD414F02576BD6afaBfb302140225;
        
        //адрес APLEX (резерв)
        reserved = 0x37F51960b8AACdFE323b616768AE18828D8F4eCD;//0x8070c0D731Efc7c041096a2D1B90805b6Db79dC6;
        
        //процент токенов переводимый на адрес APLEX (команда)
        restrictedPercent = 10;
        
        //адрес APLEX (резерв)
        reservedPercent=5;
        
        //процент токенов переводимый на адрес APLEX (bounty)
        bountyPercent=5;
        
        //количество токенов, продаваемых за 1 Ether
        //Внимание! При rate = 1 и покупке 1 APLX за 1 Ether
        //баланс окупателя увеличится на 1 * 10^18, т.к. decimals == 18
        rate = 1000;
        
        //время начала  в UNIX формате
        start = 1519761460;
        
        //продолжительность этапа в днях
        period = 28;
        
        //Возможно, введём ограничение на масмальное количество токенов на счету
        maxAccountVal = 0;
    }
    
    //Расчет максимального количество токенов, доступных к покупке
    //без этой функции можно было бы и обойтись, она носит информационный
    //характер
    function Max2BuyTokens() public view returns (uint max2buy)
    {
       //вычисляем максимальное количество токенов к покупке 
       uint max = myBalance().mul(100).div(100 + restrictedPercent + bountyPercent + reservedPercent); 
       
       //обнуляем остаток
       max2buy=max.div(rate).mul(rate); 
    }
    
  
    //функция покупки токенов с переводом на служебные адреса
    function buyTokens() public canBuy  payable
    {
        //оплачено токенов
        uint tokens = rate.mul(msg.value);
        
        //проверяем не установлено ли максимальное значение количества токенов на счету,
        //и не превышаем ли мы его покупкой
        require(maxAccountVal==0 || tokens.add(token.getBalance(msg.sender)) <= maxAccountVal);
        
        //токены на адрес команды
        uint restrictedTokens = tokens.mul(restrictedPercent).div(100);
        
        //токены на адрес команды для bounty
        uint bountyTokens = tokens.mul(bountyPercent).div(100);
        
        //токены на адрес команды резерв
        uint reservedTokens = tokens.mul(reservedPercent).div(100);
        
        //всего нужно списать токенов с баланса агента
        uint totaltokens=tokens.add(restrictedTokens).add(bountyTokens).add(reservedTokens);
        
        //проверяем доступность нужного количества токенов
        require( totaltokens <= myBalance());
      
        //получаем адрес контракта управления инветстициями
        InvestmentsStorage ist = InvestmentsStorage(selector.investmentsStorage());
        
        //Отправляем средства в investmentsStorage с указанием отправителя 
        //и номера этапа 
        ist.AddWei.value(msg.value)(msg.sender, stagenum);
        
        //переводим токены команда
        token.transferFromAgent(restricted, restrictedTokens);
        
        //переводим токены bounty
        token.transferFromAgent(bounty, bountyTokens);
        
        //переводим токены резерв
        token.transferFromAgent(reserved, reservedTokens);
        
        //переводим токены покупателю
        token.transferFromAgent(msg.sender, tokens); 
       
    }
    
     //Закрытие этапа (только владелец) 
    function finalizeSale() public onlyOwner returns (bool)
    {
        //если окончание по времени или осталось меньше rate токенов
        //меньше rate за 1 wei не купишь, такие значения могут оставаться после 
        //расчета процентов, поэтому их просто сжигаем  
        //(напоминаю 1 токен на счету - это balances[address]==1*10^18)
        if (now > saleEnd() || Max2SpendWei()<1) 
        {
            //сжигаем остатки
            token.burnAllOfAgent();
            
            //выставляем окончание продаж
            token.setEndSales();
            return true;
        }
      
        return false;
    }
}