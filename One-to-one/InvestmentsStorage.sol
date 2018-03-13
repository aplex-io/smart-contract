pragma solidity ^0.4.20;


import 'browser/WithVersionSelector.sol';
import 'browser/BasicToken.sol';
import 'browser/SafeMath.sol';


/**
* Контракт предназначен для управления средствами,
* поступающими в ходе кампании ICO (preICO).
* 
* Агент продаж мгновенно перечисляют все средства 
* на счёт контракта InvestmentsStorage.
* 
* InvestmentsStorage переводит средства на счёт APLEX только в двух случаях:
* 1) на этапе preICO (эти средства добровольно переводятся инвесторами с риском
*    потери, т.к.  не могут быть возвращены. При этом инвесторы получают
*    максимальную доходность за счёт бонуса);
* 2) при достижении условий софткапа.
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
    
    //количество средств, полученных на этапе preSale
    uint public presalewei=0;
    
    //количество средств, полученных на этапе MainSale
    uint public mainsalewei=0;
    
    //количество средств, полученных на этапе MainSale2
    uint public mainsale2wei=0;
    
    //условия софткап - при достижении все средства переводятся на счёт APLEX
    uint public constant softcap=8000 * 1 ether;
    
    //блокировка вывода средств 
    bool public blockWithdraw = true;
    
    //количество средств, переведённых на счёт APLEX
    uint public transferred2Multisig=0;
    
    //запрещает перевод средств на счёт APLEX после preSale и до достижения
    //софткап
    bool public stage0ended=false;
    
    
    //адрес счёта APLEX
    address constant multisig=0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
    
    
    //конструктор
    function InvestmentsStorage(address _versionSelectorAddress) WithVersionSelector(_versionSelectorAddress) public
    {
    
    }
    
    //fallback функция
    function() public payable 
    {
        //при прямом вызове средства переводятся на счёт APLEX
        multisig.transfer(msg.value);
        transferred2Multisig.add(msg.value);
    }
    
    //показывает баланс хранилища InvestmentsStorage
    function  getBalance() public view returns(uint)
    {
        return this.balance;
    }
    
    //показывет общее количество средств, полученных за 3 этапа ICO
    function GetTotalInvestments() public view returns(uint) {
        return presalewei.add(mainsalewei).add(mainsale2wei);
    }
    
    //функция (принимает ether) вызываемая агентами продажи при полкупке токенов APLX
    function AddWei(address investor,  uint stagenum) payable public 
    {
        //должна вызываться агентом продажи
        require(msg.value>0 && address(selector)!=0 && msg.sender==address(selector.curSaleAgentAddress()));
        
        //Условие stage0ended==false проверяется, чтобы запретить
        //увеличение presalewei а тем самым и GetTotalInvestments до 
        //любых значений путём создания агента и многократного 
        //вызова через него addwei с stagenum==0,
        //выводом денег и повторного вызова
        if (stagenum==0 && stage0ended==false)
        {
            //preICO
            
            //увеличиваем значение сборов за этап
            presalewei=presalewei.add(msg.value);
            
            //переводим на адрес APLEX
            multisig.transfer(msg.value);
            
            //увеличиваем сумму переведённых средств
            transferred2Multisig.add(msg.value);
            
            //НЕ заполняем Investors2wei!!!
        }
        else if (stagenum==1)
        {
            //MainSale
            
            //если начался 1 этап, то закрываем этап preICO (см. выше)
            if (!stage0ended)
            {
                stage0ended=true;
            }
            
            //увеличиваем значение сборов за этап
            mainsalewei=mainsalewei.add(msg.value);
            
            //запоминаем, сколько вложил инвестор
            investor2wei[investor]=investor2wei[investor].add(msg.value);
        }
        else if (stagenum==2)
        {
            //MainSale2
    
            //увеличиваем значение сборов за этап
            mainsale2wei=mainsale2wei.add(msg.value);
            
            //запоминаем, сколько вложил инвестор
            investor2wei[investor]=investor2wei[investor].add(msg.value);
        }
        else
        {
            //оставляем возможность появления агента,
            //который будет использовать storage с автопереводом на multisig
            //Делаем это без записи в Investors2wei в целях гарантии возможности
            //вывода средств инвесторами этапов MainSale и  MainSale2 при 
            //недостижении софткапа
            
            //пеервод на счёт APLEX
            multisig.transfer(msg.value);
            transferred2Multisig.add(msg.value);
        }
        
        
        //Перевод всех средств на счёт APLEX по достижении софткапа
        if (GetTotalInvestments()>=softcap)
        {
            TranferAll2Multisig();
        }
    }
    
    //Перевод всех средств на счёт APLEX
    function TranferAll2Multisig() private
    {
        uint val=this.balance;
        multisig.transfer(val);
        transferred2Multisig.add(val);
    }
    
    //Закрытие последнего этапа ICO (вызывается из VersionSelector)
    //проверяет условия софткап и переводит все средства на счёт 
    //APLEX (при достижении), либо разюлокирует возврат в противном случае
    function finalizeLastStage() public
    {
        //проверка VS
        require(address(selector)!=0 && msg.sender==address(selector));
        
        //Проверка условтй софткапа
        if (GetTotalInvestments()<softcap)
        {
            //разблокировка
            blockWithdraw=false;
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
       
        uint bal=0;
        
        //если VS всё ещё содержит адрес токена APLX
        if (selector.curAPLXTokenAddress()!=0)
        {
            //получаем баланс инвестора в токенах APLX
            bal=BasicToken(selector.curAPLXTokenAddress()).balanceOf(msg.sender);
        }
        
        //если токенов у инвестора нет
        require(bal==0);
        
        //получаем количество инвестированных средств
        uint val=investor2wei[msg.sender];
        
        //обнуляем количество инвестированных средств
        investor2wei[msg.sender]=0;
        
        //переводим инвестору
        msg.sender.transfer(val);
    }
}