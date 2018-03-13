pragma solidity ^0.4.20;

import 'browser/WithSaleAgent.sol';
import 'browser/BurnableToken.sol';
import 'browser/ExchangableFromAPLX.sol';

/**
* Контракт токена APLX. используемого для 
* сбора средств в ходе распродажи токенов на ICO (preICO)
* 
* BurnableToken - сжигаемый utility токен ERC20 с фиксированным выпуском
* WithSaleAgent - поддержка продажи агентами системы контрактов APLEX ICO
*/
contract APLXToken is BurnableToken, WithSaleAgent {

    //название токена
    string public constant name = "APLEX Token";

    //короткое название токена
    string public constant symbol = "APLX";
    
    //количество разрядов - означает, что 
    //адрес, на счету которого имеется 1 APLX
    //имеет баланс 1 * 10^18 в словаре счетов balances
    uint32 public constant decimals = 18;
    
    //количество выпускаемых токенов
    uint256 public constant initial_supply = 41000000 * 1 ether;
    
    //Конструктор
    function APLXToken(address _selector) WithSaleAgent(_selector)  public {
        totalSupply = initial_supply;
        balances[msg.sender] = initial_supply;
    }
    
    //Функция сжигания на токен APLC с сжиганием APLX
    function BurnWithExchange(uint amount) public
    {   
        //доступна после снятия блокировки обмена, при достсточном количестве APLX на счету 
        //владельца, вызвавшего Функцию, при выставленном адресе контракта токена APLC в VS 
        require(!blockExchange && balances[msg.sender]>=amount && selector.curAPLCTokenAddress() != address(0));
        
        //сначала сжигаем
        burn(amount);
        
        //получаем адрес токена APLC
        ExchangableFromAPLX exto=ExchangableFromAPLX(selector.curAPLCTokenAddress());
        
        //Выпускаем APLC на адрес пользователя
        exto.MintForExchange(msg.sender, amount);
    }
 
    //получение текущего баланса агента
    function getAgentBalance() public view returns (uint agentbalance)
    {
        require(saleAgent!=0x0);
        return balances[saleAgent];
    }
     
    //перевод токенов со счета агента (только агент)
    function transferFromAgent(address _to, uint _value) public isSaleAgent returns (bool) {
        require(_to != 0x0);
        return transfer(_to, _value);
    } 
   
    //перевод токенов на счёт агента (только владелец)
    function transferToAgent(uint _value) public onlyOwner returns (bool) {
        require(saleAgent != 0x0);
        
        return transfer(saleAgent, _value);
    }
    
    
    //проверка возможности перевода токенов между счетами
    function ValidateTransfer() public view returns(bool)
    {
        //владельцу и агенту продажи (при совпадением с агентом в VS)  можно всегда
        if (msg.sender==owner || (address(selector) != 0 && selector.curSaleAgentAddress()==saleAgent && msg.sender==saleAgent))
            return true; 
        
        //Если ICO не закончено, то нельзя    
        if (endSales == 0)
            return false;
        else
        {
            //можно, если текущее время больше чем то, которое получится если
            //ко времени окончания ICO прибавить время, на которое 
            //установлена блокировка для адреса отправителя
            //(если блокировка не установлена, то текущее время будет больше
            //endSales и проверка пройдена )
            return endSales.add(blocked[msg.sender]) < now;
        }
         
    }
    
    //перевод со токенов счета отправителя на адрес _to в количестве _value 
    function transfer(address _to, uint _value) public  returns (bool)
    {
        //проверка воможности операции
        require(ValidateTransfer());  
        //перевод
        return super.transfer(_to,  _value);
    }
    
    //сжигание всех токенов агента (только агент)
    function burnAllOfAgent() public isSaleAgent
    {
        //Если есть, что сжигать
        if (getAgentBalance()>0)
            burn(balances[saleAgent]);
    }
}