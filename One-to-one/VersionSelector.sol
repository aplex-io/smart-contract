pragma solidity ^0.4.20;

import 'browser/Ownable.sol';
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
contract VersionSelector is Ownable, IVersionSelector  {

    address public curAPLXTokenAddress;
    ExchangableFromAPLX public curAPLCTokenAddress;
    address public curMarketAddress;
    address public curSaleAgentAddress;
    InvestmentsStorage public investmentsStorage;
    
    

    function VersionSelector() public {
        investmentsStorage=new InvestmentsStorage(address(this));
    }

  function setCurMarketAddress(address _newaddr) public onlyOwner {
 
      curMarketAddress = _newaddr;
  }
 
  function setCurAPLXTokenAddress(address _newaddr) public onlyOwner {
       
      curAPLXTokenAddress = _newaddr;
      
   }
   
    function setCurAPLCTokenAddress(address _newaddr) public onlyOwner {
       
      curAPLCTokenAddress = ExchangableFromAPLX(_newaddr);
      
   }
   
  function setCurSaleAgentAddress(address _newaddr) public onlyOwner {
     
      if (WithSaleAgent(curAPLXTokenAddress).getAgent() == _newaddr || WithSaleAgent(curAPLXTokenAddress).setSaleAgent(_newaddr))
      {
           curSaleAgentAddress = _newaddr;
           
      }
     
  }
  
  function UnblockExchangeAPLX() public onlyOwner
  {
      WithSaleAgent(curAPLXTokenAddress).UnblockExchange();
  }

// 
    
   function transferToAgent(uint amount) public onlyOwner returns(bool res) {
        res = false;
        require(address(curAPLXTokenAddress)!=0 && curSaleAgentAddress!=0 && WithSaleAgent(curAPLXTokenAddress).getAgent()==curSaleAgentAddress);
        res = WithSaleAgent(curAPLXTokenAddress).transferToAgent(amount);
    }
    
    
    function finalizeAgentSale() public  returns(bool res) {
        res = false;
        require(curAPLXTokenAddress!=0 && curSaleAgentAddress!=0 && WithSaleAgent(curAPLXTokenAddress).getAgent()==curSaleAgentAddress);
        
        if (Sale(curSaleAgentAddress).finalizeSale())
        {
            setCurSaleAgentAddress(0);
            if (WithSaleAgent(curAPLXTokenAddress).endSales()!=0)
            {
                investmentsStorage.finalizeLastStage();
            }
            res = true;   
        }
    }
    
    
    //Функции Create**** сделаны для удобства отладки и позволяют сразу становится 
    // владельцем создаваемых контрактов. При необходимости создания новой версии извне
    // нужно будет  выставлять агента продажи в токене а потом вызывать tranferownership(адрес VS) у регистрируемого контракта 
    
    function CreatePresale() public onlyOwner  {
        require(address(curAPLXTokenAddress) != 0x0);
        Sale psa=new PreSale(this);
        require(address(psa)!=0x0);
        //uint amount=psa.saleTokenLimit();//  Не работает AtAddress после такого преобразования при Enviroment JavaSript VM, хотя в тестовой KovanNet вроде работало норм
        uint amount=1000000000000000000000000; //1300
        if (WithSaleAgent(curAPLXTokenAddress).setSaleAgent(address(psa)))
        {
            
            require(amount > 0);
            if (WithSaleAgent(curAPLXTokenAddress).transferToAgent(amount))
            {
                curSaleAgentAddress = psa;
                return;
            }
            PreSale(psa).killme();
        }
        PreSale(psa).killme();
        
    }
    
    
    function getsaleAgentBalance() public view returns(uint agentbal)
    {
        return Sale(curSaleAgentAddress).myBalance();
    }
    
    function CreateMainsale() public onlyOwner  {
        
        require(address(curAPLXTokenAddress) != 0x0);
        MainSale msa=new MainSale(this);
        require(address(msa)!=0x0);
        //uint amount=msa.saleTokenLimit();
        uint amount=10 ether;//25000000000000000000000000;
        if (WithSaleAgent(curAPLXTokenAddress).setSaleAgent(msa))
        {
            
            require(amount > 0);
            if (WithSaleAgent(curAPLXTokenAddress).transferToAgent(amount))
            {
                curSaleAgentAddress = msa;
                return ;
            }
           MainSale(msa).killme();
           return;
        }
        
        MainSale(msa).killme();
        return ;
    }
    
     function CreateMainsale2() public onlyOwner  {
        
        require(address(curAPLXTokenAddress) != 0x0);
        MainSale2 msa=new MainSale2(this);
        require(address(msa)!=0x0);
        //uint amount=msa.saleTokenLimit();
        uint amount=50000 ether;//25000000000000000000000000;
        if (WithSaleAgent(curAPLXTokenAddress).setSaleAgent(address(msa)))
        {
            
            require(amount > 0);
            if (WithSaleAgent(curAPLXTokenAddress).transferToAgent(amount))
            {
                curSaleAgentAddress = msa;
                return ;
            }
           MainSale2(msa).killme();
           return;
        }
        
        MainSale2(msa).killme();
        
    }
    
     function CreateAPLXToken() public onlyOwner returns (address) {
               
               address token=address(new APLXToken(address(this)));
               setCurAPLXTokenAddress(token);
               return token;
    }
    
 
}
