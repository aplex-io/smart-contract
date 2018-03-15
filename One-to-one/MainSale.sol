pragma solidity ^0.4.20;

import 'browser/InvestmentsStorage.sol';
import 'browser/Sale.sol';

/**
* Контракт агента продажи токенов APLX. Получает токены на свой счёт и продаёт
* их в рамках 1-го этапа ICO .
* Полученные средства незамедлительно переводятся на счёт контракта управления 
* инветстициями InvestmentsStorage, где блокируются до достижения софткапа или 
* окончания 2-го этапа ICO.
* 
* - В случае, если софткап достигнут средства переводятся на счёт APLEX
* - В случае если, софткап не достигнут, инвесторы могут вывести свои средства
*   самостоятельно, предварительно сжигая свои токены.
*  
*  Старт этапа: 23 июля 2018 года 
* 
*  Период проведения 28 дней
*  
*  Условия бонусов:
*  по времени:
*  1 неделя 20%
*  2 неделя 10%
*  3 неделя Не предусмотрено
*  4 неделя Не предусмотрено
* 
*  по размеру покупки X:
*    X  < 10(ETH)   Не предусмотрено
*   10 <= X < 50(ETH)    5%
*   50 <= X < 100(ETH)   10%
*    X >= 100(ETH)       15%
*/
contract MainSale is Sale {
    //Конструктор
    function MainSale(address _versionSelectorAddress) Sale(_versionSelectorAddress) public {
        
        //Количество токенов для продажи
        saleTokenLimit = 25000000 * 1 ether;
        
        //номер этапа
        stagenum=1;
        
        //адрес APLEX (команда)
        restricted = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        
        //адрес APLEX (bounty)
        bounty = 0x583031D1113aD414F02576BD6afaBfb302140225;
        
        //адрес APLEX (резерв)
        reserved = 0x8070c0D731Efc7c041096a2D1B90805b6Db79dC6;
        
        //время, на которое блокирууются токены на счету restricted
        uint restrictedBlockTime = 183 * 1 days;
        
        //время, на которое блокирууются токены на счету reserved
        uint reservedBlockTime = 1 years;
        
        //добавляем блокировку для счета команды
        token.AddBlockTime(restricted, restrictedBlockTime);
            
        //добавляем блокировку для счета резерва
        token.AddBlockTime(reserved, reservedBlockTime);
        
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
        //получаем баланс агента
        uint balance=myBalance();
        
        //процент бонусов по времени
        uint tpercent = 0;
        
        // Если прошло менее 2 недель
        if (now.sub(start) < 2 weeks)
        {
            tpercent = 10; //то 10%
        }
        
        // Если прошло менее 1 недели
        if (now.sub(start) < 1 weeks)
        {
            tpercent = 20; //то 20%
        }
        
        //рассчет общего процента на служебные адреса
        uint percent = restrictedPercent + bountyPercent + reservedPercent;
        
        //Сначала рассчитаем необходимый минимальный баланс агента для 
        //покупки с затратами от 100 ether
        uint maxwei = 100 ether;
        
        //процент бонусов покупателю складывается из 
        //процента за время и 15 процентов за затраты более 100 ETH
        uint lastBuyerPercent=tpercent + 15;
        
        //на бонусы покупателю при затратах в 100 ETH нужно будет выделить 
        //100*rate*lastBuyerPercent/100 токенов
        uint maxbonused = maxwei * rate * lastBuyerPercent / 100;
        
        //добавляем процент на служебный адреса
        uint total =  maxbonused * percent / 100;
        
        //Внутренняя переменная
        uint max;
        
        //Если баланс агента позволяет купить токенов на 100 ETH, со всеми
        //отчислениями и бонусами, то расчёт максимальной покупки производитсяи,
        //исходя из бонусов за размер 15%
        if (total <= balance)
        {
             //                                 100*100*myBalance()
             //max = ---------------------------------------------------------------------------
             //      100*100 + 100 * lastBuyerPercent + 100 * percent + lastBuyerPercent*percent
             max = myBalance().mul(10000).div(percent*100 + lastBuyerPercent*100 + percent*lastBuyerPercent + 10000);
             //избавляемся от остатка
             max2buy=max.div(rate).mul(rate); 
             return;
        }
        
        //Если баланс агента меньше, то рассчитываем аналогично для меньших 
        //значений размера бонусов
        
        //========================== для 50 <= X < 100 ETH ========================
        maxwei = 50 ether;
        //процент бонусов покупателю складывается из 
        //процента за время и 10 процентов за затраты более 50 ETH
        lastBuyerPercent = tpercent + 10;
        
        //на бонусы покупателю при затратах в 50 ETH нужно будет выделить 
        //100*rate*lastBuyerPercent/100 токенов
        maxbonused = maxwei * rate * lastBuyerPercent / 100;
        
        //добавляем процент на служебный адреса
        total =  maxbonused * percent / 100;
        
        //Если баланс агента позволяет купить токенов на 50 ETH
        if (total <= balance)
        {
              max = myBalance().mul(10000).div(percent*100 + lastBuyerPercent*100 + percent*lastBuyerPercent + 10000);
             //избавляемся от остатка
             max2buy=max.div(rate).mul(rate); 
             return;
        }
        
        //Если баланс агента меньше, то рассчитываем аналогично для меньших 
        //значений размера бонусов
        
        //========================== для 10 <= X < 50 ETH ======================
        maxwei = 10 ether;
        //процент бонусов покупателю складывается из 
        //процента за время и 5 процентов за затраты более 10 ETH
        lastBuyerPercent = tpercent + 5;
        
        //на бонусы покупателю при затратах в 10 ETH нужно будет выделить 
        //100*rate*lastBuyerPercent/100 токенов
        maxbonused = maxwei * rate * lastBuyerPercent / 100;
        
        //добавляем процент на служебный адреса
        total =  maxbonused * percent / 100;
        
        //Если баланс агента позволяет купить токенов на 50 ETH
        if (total <= balance)
        {
              max = myBalance().mul(10000).div(percent*100 + lastBuyerPercent*100 + percent*lastBuyerPercent + 10000);
             //избавляемся от остатка
             max2buy=max.div(rate).mul(rate); 
             return;
        }
        
        //В остальных случаях остаётся только процент за время
        lastBuyerPercent = tpercent;
        
        max = myBalance().mul(10000).div(percent*100 + lastBuyerPercent*100 + percent*lastBuyerPercent + 10000);
       //избавляемся от остатка
        max2buy=max.div(rate).mul(rate);
    }
   
   //функция покупки токенов с бонусами и переводом на служебные адреса 
   function buyTokens() public canBuy payable
   {
        //оплачено токенов
        uint tokens = rate.mul(msg.value);
      
        //бонус за количество      
        uint qbonus=0;
        
        //если потратили более 10 эфир, то + 5%
        if (msg.value >= 10 ether)
        {
            qbonus = tokens.div(20); 
        }
        
        //если потратили более 50 эфир, то + 10%
        if (msg.value >= 50 ether)
        {
            qbonus = tokens.div(10);
        }
        
        //если потратили более 100 эфир, то + 15%
        if (msg.value >= 100 ether)
        {
            qbonus =  tokens.mul(15).div(100); 
        }
       
        //бонус за время
        uint tbonus=0; 
        
        //если 2-я неделя, то 10%
        if (now.sub(start) < 2 weeks)
        {
            tbonus=tokens.div(10); 
        }
        
        //если 1-я неделя, то 20%
        if (now.sub(start) < 1 weeks)
        {
            tbonus=tokens.div(5); 
        }
        
        //всего токенов с бонусами
        uint bonused = tokens.add(qbonus).add(tbonus);
        
        //проверяем не установлено ли максимальное значение количества токенов на счету,
        //и не превышаем ли мы его покупкой
        require(maxAccountVal==0 || bonused.add(token.getBalance(msg.sender)) <= maxAccountVal);
        
        //токены на адрес команды
        uint restrictedTokens = bonused.mul(restrictedPercent).div(100);
        
        //токены на адрес команды для bounty
        uint bountyTokens = bonused.mul(bountyPercent).div(100);
        
        //токены на адрес команды резерв
        uint reservedTokens = bonused.mul(reservedPercent).div(100);
        
        //всего нужно списать токенов с баланса агента
        uint totaltokens=bonused.add(restrictedTokens).add(bountyTokens).add(reservedTokens);
        
        //проверяем доступность нужного количества токенов
        require(totaltokens <= myBalance());
      
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
        
        //переводим токены с бонусами покупателю
        token.transferFromAgent(msg.sender, bonused); 
    }
    
    
    //Закрытие этапа (только владелец) 
    function finalizeSale() public onlyOwner returns (bool)
    {
        //если окончание по времени или осталось меньше rate токенов
        //меньше rate за 1 wei не купишь, такие значения могут оставаться после 
        //расчета процентов, поэтому их просто сжигаем  
        //(напоминаю 1 токен на счету - это balances[address]==1*10^18)
        if (now > saleEnd() || Max2SpendWei()<1 ) 
        {
           //сжигаем остатки
           token.burnAllOfAgent();
           return true;
        }
        
        return false;
    }
}