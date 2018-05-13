pragma solidity ^0.4.20;


import 'browser/WithVersionSelector.sol';
import 'browser/BasicToken.sol';
import 'browser/SafeMath.sol';


/**
* Контракт предназначен для управления средствами,
* поступающими в ходе кампании ICO.
* Контракт является родителем для SaleAgent
* 
* 
* InvestmentsStorage переводит средства на счёт APLEX только в двух случаях:
* 1) на этапе PrivateSale (эти средства добровольно переводятся инвесторами с риском
*    потери, т.к.  не могут быть возвращены. При этом инвесторы получают
*    максимальную доходность за счёт бонуса);
* 2) при достижении условий софткапа этапа.
* 
* InvestmentsStorage позволяет инвестору самостоятельно вернуть вложенные
* средства после окончания ICO, если не достигнуты условия софткапа, посредством
* вызова функции WithdrawMyInvestments за счёт (затраты на газ) инвестора. Перед
* возвратом средств инвестор обязан самостоятельно сжечь все токены APLX,
* подтверждая тем самым своё осознанное желание выйти из финансирвания проекта.
*/
contract InvestmentsStorage is WithVersionSelector
{
    using SafeMath for uint;
    
    //словарь адрес инвестора -> количество вложенных средств в wei
    mapping(address => uint256) investor2wei;
    
    //получение количество вложенных средств в wei по адресу investor
    function investmentOf(address investor) public constant returns (uint256 balance)
    {
        balance = investor2wei[investor];
    }
    
    //количество средств, полученных на текущем этапе
    uint public gotwei = 0;
    
    
    //условия софткап этапа - при достижении все средства переводятся на счёт APLEX
    uint public stagecap;
    
    //блокировка вывода средств 
    bool public blockWithdraw = true;
    
    //количество средств, переведённых на счёт APLEX
    uint public transferred2Multisig = 0;
    
    //адрес счёта APLEX
    address constant multisig = 0x9A0e9274883dE02B52325739CfeAD7fB6dA4058d;//0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
    
    //показывает воможен ли возврат средств
    bool public isRefundable = false;
    
    //конструктор
    function InvestmentsStorage(address _versionSelectorAddress, uint _stagecap, bool _isRefundable) WithVersionSelector(_versionSelectorAddress) public
    {
        stagecap = _stagecap;
        isRefundable = _isRefundable;
    }
    
 
    //показывает баланс хранилища InvestmentsStorage
    function  getBalance() public view returns(uint)
    {
        return address(this).balance;
    }
  
    //функция вызываемая агентами продажи при полкупке токенов APLX
    function AddWei(address investor) internal 
    {
        //должна вызываться агентом продажи
        require(msg.value>0 && address(selector)!=0 && msg.sender==address(selector.curSaleAgentAddress()));
        
       
        //увеличиваем значение сборов за этап
        gotwei=gotwei.add(msg.value);
        
        //Если этап возвртный, то обновляем инвестору значение инвестиций 
        if (isRefundable)
        {
            //запоминаем, сколько вложил инвестор
            investor2wei[investor]=investor2wei[investor].add(msg.value);
        }
        
        
        //Перевод всех средств на счёт APLEX по достижении софткапа или при невозвратном этапе
        if (gotwei >= stagecap || isRefundable == false)
        {
            TranferAll2Multisig();
        }
    }
    
    //Перевод всех средств на счёт APLEX
    function TranferAll2Multisig() private
    {
        uint val = address(this).balance;
        multisig.transfer(val);
        transferred2Multisig.add(val);
    }
    
    //Закрытие этапа ICO (вызывается при закрытии этапа)
    //проверяет условия софткап и переводит все средства на счёт 
    //APLEX (при достижении), либо разблокирует возврат в противном случае
    function finalizeStage() public
    {
        //проверка VS
        require(address(selector)!=0 && msg.sender==address(selector));
        
        //Проверка условтй софткапа
        if (gotwei < stagecap)
        {
            //разблокировка
            blockWithdraw = false;
        }
        else
        {
            //перевод на счёт APLEX
            //по идеее в этом случае всё уже
            //должно быть переведено на счёт APLEX
            TranferAll2Multisig();
        }
    }
    
    //Функция вывода средств при недостижении софткапа
    function WithdrawMyInvestments() public
    {
        //проверка блокировки
        require(!blockWithdraw);
       
        uint bal = 0;
        
        //если VS всё ещё содержит адрес токена APLX
        if (selector.curAPLXTokenAddress() != 0)
        {
            //получаем баланс инвестора в токенах APLX
            bal = BasicToken(selector.curAPLXTokenAddress()).balanceOf(msg.sender);
        }
        
        //если токенов у инвестора нет
        require(bal == 0);
        
        //получаем количество инвестированных средств
        uint val = investor2wei[msg.sender];
        
        //обнуляем количество инвестированных средств
        investor2wei[msg.sender] = 0;
        
        //переводим инвестору
        msg.sender.transfer(val);
    }
}