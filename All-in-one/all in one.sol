pragma solidity ^0.4.18;

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
    var sndr=msg.sender;
    // SafeMath.sub will throw if there is not enough balance.
    balances[sndr] = balances[sndr].sub(_value);
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
    
    /* modifier isSaleAgentOrOwner {
         require(address(selector)!=0x0 || msg.sender==owner());
         require(saleAgent != 0x0 || msg.sender==owner());
         require(VersionSelector(selector).getCurSaleAgentAddress() == msg.sender || msg.sender==owner()); //проверяем установлен ли saleAgent в VersionSelector 
         //Можно ещё проверку текущего адреса токена в version selector проверить, но по идее это не здесь
         require(msg.sender == saleAgent || msg.sender==owner());
         _;
     }*/
     
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
     
     function setSaleAgent(address newAgent) public onlyOwner returns(bool res) {
         saleAgent = newAgent;
         res = saleAgent == newAgent;
     }
     
     
    function getAgent() public view returns (address agent)
    {
        return saleAgent;
    }
    
    function transferFromOwner(address _to, uint _value) public isSaleAgentOrOwner returns (bool);
    
}



contract APLXToken is BurnableToken, WithSaleAgent {

    string public constant name = "Aplex Token";

    string public constant symbol = "APLX";

    //пока решение не принято преношу в конструктор
    //uint32 public constant decimals = 18;
    
    uint8 public decimals;
    
    uint256 public initial_supply = 100000 * 1 ether;

   function APLXToken(address _selector, uint8 dec) WithSaleAgent(_selector)  public {
        totalSupply = initial_supply;
        balances[msg.sender] = initial_supply;
        decimals=dec;
    }

   function getAccountInvestment(address _investor) public view returns(uint curEther)
   {
        uint tokens=balances[_investor];
        if (tokens==0 )
            return 0;
        
         require(address(selector)!=0x0);
         require(saleAgent != 0x0);
         require(VersionSelector(selector).getCurSaleAgentAddress() == getAgent());
        
        //при вычислении таким образом возвращается значение с бонусами, ну можно назвать это бонус за владение токенами
        //в реальности могло быть потрачено меньше (выход  - хранить реальные цифры затрат или струтктуру реал, добавлено)
        curEther = tokens.div(Sale(getAgent()).rate()); //пока без учета decimals
        
   }

   /* modifier onlyOwnerOrContractsWithSameOwner() {
        uint codeLength;
        address snd=msg.sender;
        assembly
        {
            codeLength := extcodesize(snd)
        }

        if (codeLength > 0) {
            Ownable sender = Ownable(msg.sender);
        }

        require(msg.sender == owner() || (codeLength > 0 && address(sender) != 0x0 && sender.owner() == owner()));
        _;
    }*/
    
    
    
    function transferFromOwner(address _to, uint _value) public isSaleAgentOrOwner returns (bool) {
        require(_to != address(0));
        address _from=owner();
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
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
    uint8 dec;
    

    function VersionSelector(uint8 tokenDec) public {
        dec=tokenDec;
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
        if (curTokenAddress.setSaleAgent(_newaddr))
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
    
    
    
    //Функции Create**** сделаны для удобства отладки и позволяют сразу становится 
    // владельцем создаваемых контрактов. При необходимости создания новой версии извне
    // нужно будет вызывать высталять агента продажи в токене а потом вызывать tranferownership(адрес VS) у регистрируемого контракта 
    
    function CreatePresale() public onlyOwner returns (address) {
        require(address(curTokenAddress) != 0x0);
        address psa=new PreSale(address(this));
        require(psa!=0x0);
        if (curTokenAddress.setSaleAgent(psa))
        {
            curSaleAgentAddress = psa;
            return psa;
        }
        PreSale(psa).killme();
        return 0x0;
    }
    
    function CreateMainsale() public onlyOwner returns (address) {
        
        require(address(curTokenAddress) != 0x0);
        address msa=new MainSale(address(this));
        require(msa!=0x0);
        if (curTokenAddress.setSaleAgent(msa))
        {
            curSaleAgentAddress = msa;
            return msa;
        }
        MainSale(msa).killme();
        return 0x0;
    }
    
     function CreateAPLXToken() public onlyOwner returns (address) {
               address token=address(new APLXToken(address(this), dec));
               setCurTokenAddress(token);
               return token;
    }
    
 
}


contract Sale is Ownable, WithVersionSelector {
   

    using SafeMath for uint;

    address multisig;

    uint restrictedPercent;

    address restricted;
    
    WithSaleAgent public token;
    
    function buyTokens() public saleIsOn payable;

    uint public start;

    uint public period;

    uint public rate;
    
    function Sale(address _versionSelectorAddress) WithVersionSelector(_versionSelectorAddress) public {
        //получаем адрес токена от селектора
        token = WithSaleAgent(VersionSelector(_versionSelectorAddress).getCurTokenAddress());//token=new SimpleAPXToken()
        require(address(token) != 0x0);
       
        
    }

    function() external payable {
        buyTokens();
    }

    function getTokenSaleAgent() public constant returns(address agent)
    {
        agent = token.getAgent();
    }

    modifier saleIsOn() {
        //@Lavrentiy Tsvetkov - насколько стоит заморачиваться по проблеме now? (зависит от времени у майнера текущего блока)
        require(now > start && now < start + period * 1 days);
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
        start = 1515319200;
        period = 28;
    }

   uint presaleBonusPercent=40;

    function buyTokens() public saleIsOn payable {
          multisig.transfer(msg.value);
        
        
        // надо ещё раз с минимальным вложением проверить, чтобы не получлось перевода  эфира,  а купили ноль токенов
        uint tokens = rate.mul(msg.value);
        
        uint bonus;
        bonus = tokens.mul(presaleBonusPercent).div(100);
         
        uint bonused = tokens.add(bonus);
        token.transferFromOwner(msg.sender, bonused);
       
        uint restrictedTokens = bonused.mul(restrictedPercent).div(100);
        token.transferFromOwner(restricted, restrictedTokens);

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
        period = 28;
    }

   

    function buyTokens() public saleIsOn payable {
     
        multisig.transfer(msg.value);
        
        
        // надо ещё раз с минимальным вложением проверить, чтобы не получлось перевода  эфира,  а купили ноль токенов
        uint tokens = rate.mul(msg.value);
       
       
       /* Новые условия бонусов*/
       //  не претендую на истину в числах. М
        uint qbonus=0;
        
       //думаю надо учитывать предыдущие платежи  аккаунта
        uint invested=msg.value.add(APLXToken(token).getAccountInvestment(msg.sender));
        
        if (invested > 1 ether)
        {
            qbonus = tokens.div(20); //если потратили более 1 эфир, то + 5%
        }
        
        if (invested > 10 ether)
        {
            qbonus = tokens.div(10);//если потратили более 10 эфир, то + 10%
        }
        
        if (invested > 100 ether)
        {
            qbonus =  tokens.mul(15).div(100); //если потратили более 100 эфир, то + 15%
        }
        
        if (invested > 1000 ether)
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
        token.transferFromOwner(msg.sender, bonused);
       
        uint restrictedTokens = bonused.mul(restrictedPercent).div(100);
        token.transferFromOwner(restricted, restrictedTokens);

    }
}


