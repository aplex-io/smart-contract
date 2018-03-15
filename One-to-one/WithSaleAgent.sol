pragma solidity ^0.4.20;

import 'browser/WithVersionSelector.sol';
import 'browser/Ownable.sol';


/**
* Контракт обеспечивающий продажу токенов от имени агента продажи
* (виртуальный)
*/
contract WithSaleAgent is Ownable, WithVersionSelector {
    
     //адрес агента продажи
     address internal saleAgent;
     
     //словарь блокировок операций продажи с токенами после ICO
     //ключ -адрес, значение - время в unix формате, на которое 
     //устанавливается блокировка для адреса (отсчёт от окончания ICO -  endsales)
     mapping(address => uint256) blocked;
     
     //UNIX время, когда закончилось ICO (выставляется агентом при финализации)
     uint public endSales=0;
     
     //Блокировка обмена
     bool blockExchange=true;
     
     //Конструктор
     function WithSaleAgent(address _selector) WithVersionSelector(_selector) public {
     
     }
    
    //Установка времени блокировки продаж после ICO для адреса blocking на время time (UNIX формат)
    function AddBlockTime(address blocking, uint time) public isSaleAgent
    {
        blocked[blocking]=time;
    }
    
    //Установка времени окончания ICO агентом при финализации 
    function setEndSales() public isSaleAgent 
    {
        endSales=now;
    } 
    
    //Разблокровка обмена (APLX на APLC)
    function UnblockExchange() public onlyOwner
    {
        blockExchange = false;
    }
    
    //Модификатор - выполнение только агентом или владельцем
    modifier isSaleAgentOrOwner 
    {
         if (msg.sender == owner) //владелец
         {
            _;
         }
         else
         {
             require(address(selector)!=0x0 ); //VersionSelector непустой
             require(saleAgent != 0x0 ); //агент не пустой
             require(selector.curSaleAgentAddress() == msg.sender ); //проверяем установлен ли saleAgent в VersionSelector 
             require(msg.sender == saleAgent); //агент
             _;
         }
     }
     
     //Модификатор - выполнение только агентом 
    modifier isSaleAgent 
    {
        require(address(selector)!=0x0 ); //VersionSelector непустой
        require(saleAgent != 0x0 ); //агент не пустой
        require(selector.curSaleAgentAddress() == msg.sender ); //проверяем установлен ли saleAgent в VersionSelector 
        require(msg.sender == saleAgent); //агент
        _;
    }
     
     
     //установка текущего агента (только владелец)
    function setSaleAgent(address newAgent) public onlyOwner returns(bool res) 
    {
         saleAgent = newAgent;
         res = saleAgent == newAgent;
    }
     
    //получение адреса текущего агента 
    function getAgent() public view returns (address)
    {
        return saleAgent;
    }
    
    //получение текущего баланса агента
    function getAgentBalance() public view returns (uint);
    
    //получение текущего баланса 
    function getBalance(address caller) public view returns (uint)
        
    //перевод токенов со счета агента (только агент)
    function transferFromAgent(address _to, uint _value) public returns (bool);
    
    //перевод токенов на счёт агента (только владелец)
    function transferToAgent(uint _value) public returns(bool res);
    
    //сжигание всех токенов агента (только агент)
    function burnAllOfAgent() public;
}