﻿pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
} 

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;


    
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
   
    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is /*StandardToken*/ BasicToken {
 
  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint _value) public {
    require(_value > 0);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }
 
  event Burn(address indexed burner, uint indexed value);
 
}


contract Ownable {
    
  address private  _owner;
  
  function owner() public constant returns(address o)
  {
    o=_owner;
  }
 
 
  
  
  function Ownable() public {
    _owner = msg.sender;
  }
 
 
  modifier onlyOwner() {
    require(msg.sender == _owner);
    _;
  }
 
  
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));      
    _owner = newOwner;
  }
 
}

contract WithVersionSelector
{
    address internal selector;
    
    function WithVersionSelector(address _selector) public {
        require(_selector != 0x0);
        selector=_selector;
    }
    
    
}

contract WithSaleAgent is Ownable, WithVersionSelector {
    
     address internal saleAgent;
     
     function WithSaleAgent(address _selector) WithVersionSelector(_selector) public {
     
     }
    
        modifier isSaleAgentOrOwner {
         if (msg.sender == owner())
         {
            _;
         }
         else
         {
             require(address(selector)!=0x0 );
             require(saleAgent != 0x0 );
             require(VersionSelector(selector).getCurSaleAgentAddress() == msg.sender ); //проверяем установлен ли saleAgent в VersionSelector 
             //Можно ещё проверку текущего адреса токена в version selector проверить, но по идее это не здесь
             require(msg.sender == saleAgent);
             _;
         }
     }
     
       modifier isSaleAgent {
             
             require(address(selector)!=0x0 );
             require(saleAgent != 0x0 );
             require(VersionSelector(selector).getCurSaleAgentAddress() == msg.sender ); //проверяем установлен ли saleAgent в VersionSelector 
             //Можно ещё проверку текущего адреса токена в version selector проверить, но по идее это не здесь
             require(msg.sender == saleAgent);
             _;
        }
     
     function setSaleAgent(address newAgent) public onlyOwner returns(bool res) {
         saleAgent = newAgent;
         res = saleAgent == newAgent;
     }
     
     
    function getAgent() public view returns (address agent)
    {
        return saleAgent;
    }
    
    function getAgentBalance() public view returns (uint agentbalance);
    
        
    
    
   // function transferFromOwner(address _to, uint _value) public isSaleAgentOrOwner returns (bool);
    
   // function burnAllOwned() public isSaleAgentOrOwner returns (bool);
    
    function transferFromAgent(address _to, uint _value) public isSaleAgent returns (bool);
    
    function transferToAgent(uint _value) public onlyOwner returns(bool res);
    
    function burnAllOfAgent() public isSaleAgent returns (bool);
    
}



contract APLXToken is BurnableToken, WithSaleAgent {

    string public constant name = "Aplex Token";

    string public constant symbol = "APLX";

    uint32 public constant decimals = 18;
    
    uint256 public initial_supply = 41000000 * 1 ether;

   function APLXToken(address _selector) WithSaleAgent(_selector)  public {
        totalSupply = initial_supply;
        balances[msg.sender] = initial_supply;
    }

 
    
   /* function transferFromOwner(address _to, uint _value) public isSaleAgentOrOwner returns (bool) {
        require(_to != address(0));
        address _from=owner();
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    
     function burnAllOwned() public isSaleAgentOrOwner returns (bool)
     {
        var value=totalSupply - balances[owner()];
        totalSupply = value;
        balances[owner()] = 0;
        Burn(owner(), value);
     }*/
     
     function getAgentBalance() public view returns (uint agentbalance)
     {
        require(saleAgent!=0x0);
        return balances[saleAgent];
     }
     
    function transferFromAgent(address _to, uint _value) public isSaleAgent returns (bool) {
        require(_to != 0x0);
        return  transfer(_to, _value);
    } 
     
    function transferToAgent(uint _value) public returns (bool) {
        require(saleAgent != 0x0);
        
        return transfer(saleAgent, _value);
    }
    
    function burnAllOfAgent() public isSaleAgentOrOwner returns (bool)
     {
        burn(balances[saleAgent]);
     }
   
}




/**
* Менять контракты нельзя,но выпускать новые версии можно
* Сайты, приложения, сервисы начинают общаться сетью блокчейна
* с получения адресов актуальных контрактов
*/

contract VersionSelector is Ownable {

    WithSaleAgent private curTokenAddress;
    address private curMarketAddress;
    address private curSaleAgentAddress;
    
    

    function VersionSelector() public {
        
    }

    function setCurMarketAddress(address _newaddr) public onlyOwner {
        require(_newaddr != 0);
        curMarketAddress = _newaddr;
    }

    function setCurTokenAddress(address _newaddr) public onlyOwner {
        require(_newaddr != 0);
        //Почему-то, если вставляю такую проверку, то не могу загрузить SimpleAPXToken at address
        //Хотя проверку проходит, значение записывает
        //Ownable ow=Ownable(_newaddr);
        //require(ow.owner()==address(this));
        curTokenAddress = WithSaleAgent(_newaddr);
        
    }
    
    function setCurSaleAgentAddress(address _newaddr) public onlyOwner {
        require(_newaddr != 0);
        if (curTokenAddress.getAgent() == _newaddr || curTokenAddress.setSaleAgent(_newaddr))
        {
             curSaleAgentAddress = _newaddr;
             
        }
       
    }

    
    function getCurMarketAddress() public view returns (address addr){
        addr = curMarketAddress;
    }
    
    
    function getCurTokenAddress() public view returns (WithSaleAgent addr) 
    {
        addr = curTokenAddress;
    }

    
    function getCurSaleAgentAddress() public view returns  (address addr) {
        addr = curSaleAgentAddress;
    }
    
   function transferToAgent(uint amount) public onlyOwner returns(bool res) {
        res = false;
        require(address(curTokenAddress)!=0 && curSaleAgentAddress!=0 && curTokenAddress.getAgent()==curSaleAgentAddress);
        res = curTokenAddress.transferToAgent(amount);
    }
    
    
    
    //Функции Create**** сделаны для удобства отладки и позволяют сразу становится 
    // владельцем создаваемых контрактов. При необходимости создания новой версии извне
    // нужно будет  высталять агента продажи в токене а потом вызывать tranferownership(адрес VS) у регистрируемого контракта 
    
    function CreatePresale() public onlyOwner  {
        require(address(curTokenAddress) != 0x0);
        Sale psa=new PreSale(this);
        require(address(psa)!=0x0);
       uint amount=psa.saleTokenLimit();//  Не работает AtAddress после такого преобразования при Enviroment JavaSript VM, хотя в тестовой KovanNet вроде работало норм
       //test uint amount=2000000000000000000000;//1000000000000000000000000;
        if (curTokenAddress.setSaleAgent(address(psa)))
        {
            
            require(amount > 0);
            if (curTokenAddress.transferToAgent(amount))
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
    
    function CreateMainsale() public onlyOwner returns (address) {
        
        require(address(curTokenAddress) != 0x0);
        MainSale msa=new MainSale(this);
        require(address(msa)!=0x0);
        uint amount=msa.saleTokenLimit();
        //uint amount=25000000000000000000000000;
        if (curTokenAddress.setSaleAgent(msa))
        {
            
            require(amount > 0);
            if (curTokenAddress.transferToAgent(amount))
            {
                curSaleAgentAddress = msa;
                return msa;
            }
           MainSale(msa).killme();
        }
        
        MainSale(msa).killme();
        return 0x0;
    }
    
     function CreateAPLXToken() public onlyOwner returns (address) {
               address token=address(new APLXToken(address(this)));
               setCurTokenAddress(token);
               return token;
    }
    
 
}


contract Sale is Ownable, WithVersionSelector {
   

    using SafeMath for uint;

    address multisig;

    uint restrictedPercent;

    address restricted;
    
    uint public saleTokenLimit;
    
    WithSaleAgent public token;
    
    function buyTokens() public saleIsOn payable; 
   
    function finalizeSale() public returns (bool res);
    
    uint public start;

    uint public period;

    uint public rate;
    
    function saleEnd() public view returns (uint) { return start.add(period * 1 days); }
    
    function myBalance() public view returns (uint) 
    {
        require(token.getAgent() == address(this));
        return token.getAgentBalance(); 
    }
    
    function sold() public view returns (uint) { return saleTokenLimit.sub(token.getAgentBalance()); }
    
    
    function Sale(address _versionSelectorAddress) WithVersionSelector(_versionSelectorAddress) public {
        //получаем адрес токена от селектора
        token = WithSaleAgent(VersionSelector(_versionSelectorAddress).getCurTokenAddress());//token=new SimpleAPXToken()
        require(address(token) != 0x0);
       
        
    }

    function() external payable {
        buyTokens();
    }

   
    modifier saleIsOn() {
        //@Lavrentiy Tsvetkov - насколько стоит заморачиваться по проблеме now? (зависит от времени у майнера текущего блока)
        require(now > start && now < saleEnd());
        _;
    }

    function killme() public onlyOwner {
            selfdestruct(owner());
        }
}

contract PreSale is Sale {
  
    function PreSale(address _versionSelectorAddress) Sale(_versionSelectorAddress) public {
        selector = VersionSelector(_versionSelectorAddress);
        multisig = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
        restricted = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        restrictedPercent = 25;
        rate = 1000;
        start = 1517868326;
        period = 30;
        saleTokenLimit = 1000000 * 1 ether;
        //test saleTokenLimit = 2000 * 1 ether;
        
    }

   uint presaleBonusPercent=40;
   
    
    function finalizeSale() public onlyOwner returns (bool res)
    {
        if (now > saleEnd())
        {
           token.burnAllOfAgent();
           res=true;
        }
        res = false;
    }
    
    
    
    function Max2BuyTokens() public view returns (uint max2buy)
    {
       max2buy = myBalance().mul(10000).div(restrictedPercent.mul(100).add(presaleBonusPercent.mul(100)).add(restrictedPercent.mul(presaleBonusPercent)).add(10000));
    }
    
    function Max2SpendWei() public view returns (uint maxwei)
    {
       maxwei = Max2BuyTokens().div(rate);
    }

    function buyTokens() public saleIsOn payable {
        
        
        
        uint tokens = rate.mul(msg.value);
        
        uint bonus;
        bonus = tokens.mul(presaleBonusPercent).div(100);
         
        uint bonused = tokens.add(bonus);
        uint restrictedTokens = bonused.mul(restrictedPercent).div(100);
        uint totaltokens=bonused.add(restrictedTokens);
        if ( totaltokens <= myBalance())
        {
            multisig.transfer(msg.value);
            token.transferFromAgent(msg.sender, bonused);
            token.transferFromAgent(restricted, restrictedTokens);
        }
        else
        {
            //вычисляем макимально возможное количество токенов к покупке
            uint max2buy=Max2BuyTokens();
            uint maxbonus=max2buy.mul(presaleBonusPercent).div(100);
            uint maxbonused=max2buy.add(maxbonus);
            uint maxwei=max2buy.div(rate);
            //сдача 
            uint change=msg.value.sub(maxwei); 
            multisig.transfer(maxwei);
            
            token.transferFromAgent(msg.sender, maxbonused);
            token.transferFromAgent(restricted, maxbonused.mul(restrictedPercent).div(100));
           
            msg.sender.transfer(change); //НЕ ПОЛУЧИТСЯ ЛИ ЗДЕСЬ ПОШАЛИТЬ ЧЕРЕЗ fallback() sender-а?
        }

    }
    
    
}

contract MainSale is Sale {
  
    function MainSale(address _versionSelectorAddress) Sale(_versionSelectorAddress) public {
        selector = VersionSelector(_versionSelectorAddress);
        multisig = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
        restricted = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        restrictedPercent = 25;
        rate = 1000;
        start = 1515319200;
        period = 30;
        saleTokenLimit = 25000000 * 1 ether;
    }

   

    function buyTokens() public saleIsOn payable {
      
        uint tokens = rate.mul(msg.value);
       
       
       /* Новые условия бонусов*/
       //  не претендую на истину в числах. 
        uint qbonus=0;
        
       //думаю надо учитывать предыдущие платежи  аккаунта 
       // пока решено без этого
       // uint invested=msg.value.add(APLXToken(token).getAccountInvestment(msg.sender));
       
        
        if (/*invested*/msg.value > 1 ether)
        {
            qbonus = tokens.div(20); //если потратили более 1 эфир, то + 5%
        }
        
        if (/*invested*/msg.value > 10 ether)
        {
            qbonus = tokens.div(10);//если потратили более 10 эфир, то + 10%
        }
        
        if (/*invested*/msg.value > 100 ether)
        {
            qbonus =  tokens.mul(15).div(100); //если потратили более 100 эфир, то + 15%
        }
        
        if (/*invested*/msg.value > 1000 ether)
        {
            qbonus = tokens.div(5); //если потратили более 1000 эфир, то + 20%
        }
        
        uint tbonus=0; 
        
        if (now.sub(start) < 3 weeks)
        {
            tbonus=tokens.div(20); //если 3 неделя, то 5%
        }
        
        
        if (now.sub(start) < 2 weeks)
        {
            tbonus=tokens.div(10); //если 2 неделя, то 10%
        }
        
        
        if (now.sub(start) < 1 weeks)
        {
            tbonus=tokens.mul(15).div(100); //если 1 неделя, то 15%
        }
        
        
        if (now.sub(start) < 1 days)
        {
            tbonus=tokens.div(5); //если 1 день, то 20%
        }
        
        
        uint bonused = tokens.add(qbonus).add(tbonus);
        
       
        uint restrictedTokens = bonused.mul(restrictedPercent).div(100);
       
        
        uint totaltokens=bonused.add(restrictedTokens);
        require ( totaltokens <= myBalance());
        //пока без сдачи здесь, 
        {
            multisig.transfer(msg.value);
            token.transferFromAgent(msg.sender, bonused);
            token.transferFromAgent(restricted, restrictedTokens);
        }

    }
    
    function finalizeSale() public onlyOwner returns (bool res)
    {
        if (now > saleEnd())
        {
           token.burnAllOfAgent();
           res=true;
        }
        res = false;
    }
}

contract MainSale2 is Sale {
  
    function MainSale2(address _versionSelectorAddress) Sale(_versionSelectorAddress) public {
        selector = VersionSelector(_versionSelectorAddress);
        multisig = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
        restricted = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        restrictedPercent = 25;
        rate = 1000;
        start = 1515319200;
        period = 28;
        saleTokenLimit = 15000000 * 1 ether;
    }

    function Max2BuyTokens() public view returns (uint max2buy)
    {
       max2buy = myBalance().mul(100).div(restrictedPercent.add(100));
    }
    

    function buyTokens() public saleIsOn payable 
    {
        multisig.transfer(msg.value);
        uint tokens = rate.mul(msg.value);
       
        uint restrictedTokens = tokens.mul(restrictedPercent).div(100);
        uint totaltokens=tokens.add(restrictedTokens);
        if ( totaltokens <= myBalance())
        {
            token.transferFromAgent(restricted, restrictedTokens);
            token.transferFromAgent(msg.sender, tokens); 
        }
        else
        {
            //вычисляем макимально возможное количество токенов к покупке
            uint max2buy=Max2BuyTokens();
            uint maxwei=max2buy.div(rate);
            //сдача 
            uint change=msg.value.sub(maxwei); 
            multisig.transfer(maxwei);
            
            token.transferFromAgent(msg.sender, max2buy);
            token.transferFromAgent(restricted, max2buy.mul(restrictedPercent).div(100));
           
            msg.sender.transfer(change);
        }
    }
    
    function finalizeSale() public onlyOwner returns (bool res)
    {
        if (now > saleEnd())
        {
           token.burnAllOfAgent();
           res=true;
        }
        res = false;
    }
}


