pragma solidity ^0.4.20;


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
    /* @param _versionSelectorAddress address адрес контракта VersionSelector
     * @param _restrictedAddress address адрес получателя токенов команды
     * @param _reservedAddress address адрес получателя токенов команды (резерв)
     * @param _bountyAddress address адрес получателя токенов для баунти
     * @param _start uint время начала продаж в UNIX формате
     * @param _maxAccountVal uint256 максимально возможное значение баланса на одном счету. 
     *         (Если 0, то без ограничений)
     * @param _minVal2Buy uint256 минимально возможная сумма вложения в wei.
     *         (Если 0, то без ограничений)
     */
    function MainSale2(address _versionSelectorAddress, address _restrictedAddress, address _reservedAddress, address _bountyAddress, uint _start, uint _maxAccountVal, uint _minVal2Buy, uint _stagecap, bool _isRefundable) 
                  Sale(        _versionSelectorAddress,         _restrictedAddress,         _reservedAddress,         _bountyAddress,      _start,      _maxAccountVal,      _minVal2Buy,      _stagecap,      _isRefundable) public 
   {
        //Количество токенов для продажи
        stagenum=2;
        
        //Количество токенов для продажи
        saleTokenLimit = 15000000 * 1 ether;
    
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
        
        //продолжительность этапа в днях
        period = 28;
    }
    
     //Расчет максимального количество токенов доступных к покупке,
    //не учитывающий ограничения по максимальному счёту и минимальной покупке.
    //Возвращает max2buy - максимально доступное олачиваемое количество,
    //           maxbonused = max2buy - бонусов не предусмотрено 
    function Max2BuyTokensTotal() public view returns (uint max2buy, uint maxbonused)
    {
       //вычисляем максимальное количество токенов к покупке 
       uint max = myBalance().mul(100).div(100 + restrictedPercent + bountyPercent + reservedPercent); 
       
       //обнуляем остаток
       max2buy=max.div(rate).mul(rate); 
       
       //бонусов не предусмотрено
       maxbonused = max2buy;
    }
    
    //Внутренняя переменная, для предотвращения многократного вызова функции
    //установки времени блокировки служебных адресов в контракте токена
    bool BlockTimeIsSet=false;

   //функция покупки токенов с переводом на служебные адреса 
    function buyTokens() public canBuy  payable
    {
        //Если время ещё не выставлено
        if (!BlockTimeIsSet)
        {
            //Устанавливаем блокировки. 
            token.SetBlockTime(restricted, restrictedBlockTime);
            token.SetBlockTime(reserved, reservedBlockTime);
            BlockTimeIsSet=true;
        }
        
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
      
        //проверяем не будет ли превышен лимит продаж
        require(sold.add(totaltokens) <= saleTokenLimit);
       
        //Учитываем средства в родительском investmentsStorage с указанием 
        //отправителя 
        super.AddWei(msg.sender);
        
        //переводим токены команда
        token.transferFromAgent(restricted, restrictedTokens);
        
        //переводим токены bounty
        token.transferFromAgent(bounty, bountyTokens);
        
        //переводим токены резерв
        token.transferFromAgent(reserved, reservedTokens);
        
        //переводим токены покупателю
        token.transferFromAgent(msg.sender, tokens); 
        
        //добавляем значение в количество проданных токенов
        sold = sold.add(totaltokens);
    }
    
     //Закрытие этапа (только владелец) 
    function finalizeSale() public onlyOwner returns (bool)
    {
        //если окончание по времени или токены кончились 
        if (now > saleEnd() || Max2SpendWeiTotal() == 0) 
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