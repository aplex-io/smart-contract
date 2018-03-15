pragma solidity ^0.4.20;


import 'browser/ExchangableFromAPLX.sol';
import 'browser/InvestmentsStorage.sol';
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
    
    //Контракт, собирающего инвестиции и управляющего ими
    InvestmentsStorage public investmentsStorage;


    //Конструктор
    function VersionSelector() public 
    {
        //создание контракта управления инвестициями
        investmentsStorage=new InvestmentsStorage(address(this));
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
        if (Sale(curSaleAgentAddress).finalizeSale())
        {
            //обнуляем текущего агента у токена
            curAPLXTokenAddress.setSaleAgent(0);
            
            //обнуляем текущего агента и здесь
            setCurSaleAgentAddress(0);
            
            //Если это был последний этап, должно было выть выставлено время
            //окончания продаж
            if (WithSaleAgent(curAPLXTokenAddress).endSales()!=0)
            {
                //Тогда вызываем закрытие в investmentsStorage
                investmentsStorage.finalizeLastStage();
            }
            res = true;   
        }
    }
    
    //Получает баланс текущего агента
    function getsaleAgentBalance() public view returns(uint agentbal)
    {
        return curSaleAgentAddress.myBalance();
    }
    
    //Создание агента Presale и установка текущим (только владелец)
    function CreatePresale() public onlyOwner  
    {
        require(address(curAPLXTokenAddress) != 0x0);
        PreSale sa=new PreSale(this);
        require(address(sa)!=0x0);
        uint amount=sa.saleTokenLimit();
        require(amount>0);
        require(curAPLXTokenAddress.setSaleAgent(address(sa)));
        require(curAPLXTokenAddress.transferToAgent(amount));
        curSaleAgentAddress = sa;
    }
    
    
    
    //Создание агента MainSale и установка текущим  (только владелец)
    function CreateMainSale() public onlyOwner  
    {
        require(address(curAPLXTokenAddress) != 0x0);
        MainSale sa=new MainSale(this);
        require(address(sa)!=0x0);
        uint amount=sa.saleTokenLimit();
        require(amount>0);
        require(curAPLXTokenAddress.setSaleAgent(address(sa)));
        require(curAPLXTokenAddress.transferToAgent(amount));
        curSaleAgentAddress = sa;
    }
    
    //Создание агента MainSale2 и установка текущим (только владелец)
    function CreateMainSale2() public onlyOwner  
    {
        require(address(curAPLXTokenAddress) != 0x0);
        MainSale2 sa=new MainSale2(this);
        require(address(sa)!=0x0);
        uint amount=sa.saleTokenLimit();
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
