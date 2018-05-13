pragma solidity ^0.4.20;


import 'browser/ExchangableFromAPLX.sol';
import 'browser/IVersionSelector.sol';
import 'browser/WithSaleAgent.sol';
import 'browser/PreSale.sol';
import 'browser/MainSale.sol';
import 'browser/MainSale2.sol';
import 'browser/APLXToken.sol';
import 'browser/test.sol';



/**
* Менять контракты нельзя,но выпускать новые версии можно
* Сайты, приложения, сервисы начинают общаться c сетью блокчейна
* с получения адресов актуальных контрактов. В общем случе в данном контракте 
* мы храним адреса всех используемых в системе контрактов других типов
* При реализации системы контрактов продажи токенов мы ограничиваем возможности 
* замены версий контрактов, чтобы гарантировать объявленные условия продажи
*/
contract VersionSelector is Ownable, IVersionSelector
{
    //токен APLX
    WithSaleAgent public curAPLXTokenAddress;
    
    //токен APLC
    ExchangableFromAPLX public curAPLCTokenAddress;
    
    //адрес контракта маркета (пока ен используется)
    address public curMarketAddress;
    
    //текущий агент распродажи
    Sale public curSaleAgentAddress;
    
    //Конструктор
    function VersionSelector() public 
    {
        
    }

  //Установка текущего адреса маркета (только владелец)
  function setCurMarketAddress(address _newaddr) public onlyOwner
  {
      curMarketAddress = _newaddr;
  }
 
 
   //Установка текущего адреса токена APLX (только владелец)
   function setCurAPLXTokenAddress(address _newaddr) public onlyOwner
   {
       
      curAPLXTokenAddress = WithSaleAgent(_newaddr);
      
   }
   
   //Установка текущего адреса токена APLC (только владелец)
   function setCurAPLCTokenAddress(address _newaddr) public onlyOwner
   {
      curAPLCTokenAddress = ExchangableFromAPLX(_newaddr);
   }
   
   //Установка текущего адреса агента продажи токенв APLX (только владелец)
   function setCurSaleAgentAddress(address _newaddr) public onlyOwner
   {
      //Если у токена агент совпадает или его удалось изменить
      if (WithSaleAgent(curAPLXTokenAddress).getAgent() == _newaddr || WithSaleAgent(curAPLXTokenAddress).setSaleAgent(_newaddr))
      {
           curSaleAgentAddress = Sale(_newaddr);
      }
     
   }
  
   //Разблокировка обмена APLX на APLC (только владелец)
   function UnblockExchangeAPLX() public onlyOwner
   {
       WithSaleAgent(curAPLXTokenAddress).UnblockExchange();
   }


   //Перевод средств агенту  (только владелец)
   function transferToAgent(uint amount) public onlyOwner returns(bool res)
   {
        res = false;
        //токен и агент должны быть установлены, агент здесь и в токене должны совпадать
        require(address(curAPLXTokenAddress)!=0 && address(curSaleAgentAddress)!=0 && curAPLXTokenAddress.getAgent()==address(curSaleAgentAddress));
        
        //перевод
        res = WithSaleAgent(curAPLXTokenAddress).transferToAgent(amount);
   }
    
    //Закрываем распродажу текущего агента
    function finalizeAgentSale() public  returns(bool res)
    {
        res = false;
        //токен и агент должны быть установлены, агент здесь и в токене должны совпадать
        require(address(curAPLXTokenAddress)!=0 && address(curSaleAgentAddress)!=0 && curAPLXTokenAddress.getAgent()==address(curSaleAgentAddress));
        
        //Если успешно завершили этап у агнета
        if (Sale(curSaleAgentAddress).finalize())
        {
            //обнуляем текущего агента у токена
            curAPLXTokenAddress.setSaleAgent(0);
            
            //обнуляем текущего агента и здесь
            setCurSaleAgentAddress(0);
           
            res = true;   
        }
    }
    
    //Получает баланс текущего агента
    function getsaleAgentBalance() public view returns(uint agentbal)
    {
        return curSaleAgentAddress.myBalance();
    }
    
    //Создание агента Presale и установка текущим (только владелец)
    /*
     * @param _start uint время начала продаж в UNIX формате
     * @param _maxAccountVal uint256 максимально возможное значение баланса на одном счету. 
     *         (Если 0, то без ограничений)
     */
    /* "1521628365","1000000000000000000","10000000000" */
    function CreatePresale(uint _start, uint _maxAccountVal, uint _minVal2Buy, uint _stagecap, bool _isRefundable) public onlyOwner  
    {
        require(address(curAPLXTokenAddress) != 0x0);
        PreSale sa=new PreSale(this,  _start, _maxAccountVal, _minVal2Buy, _stagecap, _isRefundable);
        require(address(sa) != 0x0);
        //uint amount = sa.saleTokenLimit();
        uint amount = 1000000 ether;
        require(amount > 0);
        require(curAPLXTokenAddress.setSaleAgent(address(sa)));
        require(curAPLXTokenAddress.transferToAgent(amount));
        curSaleAgentAddress = sa;
    }
    
    
    
    //Создание агента MainSale и установка текущим  (только владелец)
     /*
     * @param _restrictedAddress address адрес получателя токенов команды
     * @param _reservedAddress address адрес получателя токенов команды (резерв)
     * @param _bountyAddress address адрес получателя токенов для баунти
     * @param _start uint время начала продаж в UNIX формате
     * @param _maxAccountVal uint256 максимально возможное значение баланса на одном счету. 
     *         (Если 0, то без ограничений)
     */
    function CreateMainSale(address _restrictedAddress, address _reservedAddress, address _bountyAddress, uint _start, uint _maxAccountVal, uint _minVal2Buy, uint _stagecap, bool _isRefundable) public onlyOwner  
    {
        require(address(curAPLXTokenAddress) != 0x0);
        MainSale sa=new MainSale(this, _restrictedAddress, _reservedAddress, _bountyAddress, _start, _maxAccountVal, _minVal2Buy, _stagecap, _isRefundable);
        require(address(sa)!=0x0);
        uint amount=sa.saleTokenLimit();
        require(amount>0);
        require(curAPLXTokenAddress.setSaleAgent(address(sa)));
        require(curAPLXTokenAddress.transferToAgent(amount));
        curSaleAgentAddress = sa;
    }
    
    //Создание агента MainSale2 и установка текущим (только владелец)
     /*
     * @param _restrictedAddress address адрес получателя токенов команды
     * @param _reservedAddress address адрес получателя токенов команды (резерв)
     * @param _bountyAddress address адрес получателя токенов для баунти
     * @param _start uint время начала продаж в UNIX формате
     * @param _maxAccountVal uint256 максимально возможное значение баланса на одном счету. 
     *         (Если 0, то без ограничений)
     */
    function CreateMainSale2(address _restrictedAddress, address _reservedAddress, address _bountyAddress, uint _start, uint _maxAccountVal, uint _minVal2Buy, uint _stagecap, bool _isRefundable) public onlyOwner  
    {
        require(address(curAPLXTokenAddress) != 0x0);
        //"0x14723a09acff6d2a60dcdf7aa4aff308fddc160c","0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db","0x583031d1113ad414f02576bd6afabfb302140225","1521148938","0"
        //"0x37F51960b8AACdFE323b616768AE18828D8F4eCD", "0x37F51960b8AACdFE323b616768AE18828D8F4eCD","0x37F51960b8AACdFE323b616768AE18828D8F4eCD","1521148938","0"
        MainSale2 sa=new MainSale2(this, _restrictedAddress, _reservedAddress, _bountyAddress, _start, _maxAccountVal, _minVal2Buy, _stagecap, _isRefundable);
        require(address(sa)!=0x0);
        //uint amount=sa.saleTokenLimit();
        uint amount=2500000000000000000000000;
        require(amount>0);
        require(curAPLXTokenAddress.setSaleAgent(address(sa)));
        require(curAPLXTokenAddress.transferToAgent(amount));
        curSaleAgentAddress = sa;
    }
    
    //Создание токена APLX и установка текущим (только владелец)
    function CreateAPLXToken() public onlyOwner
    {
        setCurAPLXTokenAddress(address(new APLXToken(address(this))));
    }
}
