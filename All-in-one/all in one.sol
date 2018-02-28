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
             require(VersionSelector(selector).curSaleAgentAddress() == msg.sender ); //проверяем установлен ли saleAgent в VersionSelector 
             //Можно ещё проверку текущего адреса токена в version selector проверить, но по идее это не здесь
             require(msg.sender == saleAgent);
             _;
         }
     }
     
       modifier isSaleAgent {
             
             require(address(selector)!=0x0 );
             require(saleAgent != 0x0 );
             require(VersionSelector(selector).curSaleAgentAddress() == msg.sender ); //проверяем установлен ли saleAgent в VersionSelector 
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

contract InvestmentsStorage is WithVersionSelector {
    using SafeMath for uint;
    
    mapping(address => uint256) investor2wei;
    
    function investmentOf(address investor) public constant returns (uint256 balance) {
    return investor2wei[investor];
  }
    
    uint presalewei=0;
    uint mainsalewei=0;
    uint mainsale2wei=0;
    
    function InvestmentsStorage(address _versionSelectorAddress) WithVersionSelector(_versionSelectorAddress) public
    {
    
    }
    
    function GetTotalInvestments() public view returns(uint) {
        return presalewei.add(mainsalewei).add(mainsale2wei);
    }
    
    function AddWei(address investor, uint weis, uint stagenum) public 
    {
        require(selector!=0 && msg.sender==address(VersionSelector(selector).curSaleAgentAddress()));
        investor2wei[investor]=investor2wei[investor].add(weis);
        if (stagenum==0)
        {
            presalewei=presalewei.add(weis);
            return;
        }
        if (stagenum==1)
        {
            mainsalewei=mainsalewei.add(weis);
            return;
        }
        if (stagenum==2)
        {
            mainsale2wei=mainsale2wei.add(weis);
            return;
        }
    }
    
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
        transfer(_to, _value);
        
    } 
     
    function transferToAgent(uint _value) public onlyOwner returns (bool) {
        require(saleAgent != 0x0);
        
        return transfer(saleAgent, _value);
    }
    
    function burnAllOfAgent() public isSaleAgent returns (bool)
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

    WithSaleAgent public curAPLXTokenAddress;
    address public curAPLCTokenAddress;
    address public curMarketAddress;
    address public curSaleAgentAddress;
    address public curInvestmentsStorageAddress;
    
    

    function VersionSelector() public {
        curInvestmentsStorageAddress=address(new InvestmentsStorage(address(this)));
    }

  function setCurMarketAddress(address _newaddr) public onlyOwner {
 
      curMarketAddress = _newaddr;
  }
 
  function setCurInvestmentsStorageAddress(address _newaddr) public onlyOwner {
     
      curInvestmentsStorageAddress = _newaddr;
 }

   function setCurAPLXTokenAddress(address _newaddr) public onlyOwner {
       
      curAPLXTokenAddress = WithSaleAgent(_newaddr);
      
   }
   
  function setCurSaleAgentAddress(address _newaddr) public onlyOwner {
     
      if (curAPLXTokenAddress.getAgent() == _newaddr || curAPLXTokenAddress.setSaleAgent(_newaddr))
      {
           curSaleAgentAddress = _newaddr;
           
      }
     
  }

// 
    
   function transferToAgent(uint amount) public onlyOwner returns(bool res) {
        res = false;
        require(address(curAPLXTokenAddress)!=0 && curSaleAgentAddress!=0 && curAPLXTokenAddress.getAgent()==curSaleAgentAddress);
        res = curAPLXTokenAddress.transferToAgent(amount);
    }
    
    
    function finalizeAgentSale() public onlyOwner returns(bool res) {
        res = false;
        require(address(curAPLXTokenAddress)!=0 && curSaleAgentAddress!=0 && curAPLXTokenAddress.getAgent()==curSaleAgentAddress);
        
        if (Sale(curSaleAgentAddress).finalizeSale())
        {
            setCurSaleAgentAddress(0);
            res = true;   
        }
    }
    
    
    //Функции Create**** сделаны для удобства отладки и позволяют сразу становится 
    // владельцем создаваемых контрактов. При необходимости создания новой версии извне
    // нужно будет  высталять агента продажи в токене а потом вызывать tranferownership(адрес VS) у регистрируемого контракта 
    
    function CreatePresale() public onlyOwner  {
        require(address(curAPLXTokenAddress) != 0x0);
        Sale psa=new PreSale(this);
        require(address(psa)!=0x0);
        uint amount=psa.saleTokenLimit();//  Не работает AtAddress после такого преобразования при Enviroment JavaSript VM, хотя в тестовой KovanNet вроде работало норм
        //uint amount=1300;//1000000000000000000000000;
        if (curAPLXTokenAddress.setSaleAgent(address(psa)))
        {
            
            require(amount > 0);
            if (curAPLXTokenAddress.transferToAgent(amount))
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
        
        require(address(curAPLXTokenAddress) != 0x0);
        MainSale msa=new MainSale(this);
        require(address(msa)!=0x0);
        uint amount=msa.saleTokenLimit();
        //uint amount=10 ether;//25000000000000000000000000;
        if (curAPLXTokenAddress.setSaleAgent(msa))
        {
            
            require(amount > 0);
            if (curAPLXTokenAddress.transferToAgent(amount))
            {
                curSaleAgentAddress = msa;
                return msa;
            }
           MainSale(msa).killme();
        }
        
        MainSale(msa).killme();
        return 0x0;
    }
    
     function CreateMainsale2() public onlyOwner returns (address) {
        
        require(address(curAPLXTokenAddress) != 0x0);
        MainSale2 msa=new MainSale2(this);
        require(address(msa)!=0x0);
        uint amount=msa.saleTokenLimit();
        //uint amount=10 ether;//25000000000000000000000000;
        if (curAPLXTokenAddress.setSaleAgent(msa))
        {
            
            require(amount > 0);
            if (curAPLXTokenAddress.transferToAgent(amount))
            {
                curSaleAgentAddress = msa;
                return msa;
            }
           MainSale2(msa).killme();
        }
        
        MainSale2(msa).killme();
        return 0x0;
    }
    
     function CreateAPLXToken() public onlyOwner returns (address) {
               
               address token=address(new APLXToken(address(this)));
               setCurAPLXTokenAddress(token);
               return token;
    }
    
 
}



contract Sale is Ownable, WithVersionSelector {
   
    uint8 public stagenum=0;
    
    using SafeMath for uint;

    address multisig;

    uint restrictedPercent;

    uint bountyPercent;

    address restricted;
    
    address bounty;
    
    uint public saleTokenLimit;
    
    WithSaleAgent public token;
    
    function buyTokens() public canBuy payable; 
   
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
    
    function Max2BuyTokens() public view returns (uint max2buy);
   
    
    function Max2SpendWei() public view returns (uint maxwei)
    {
       maxwei = Max2BuyTokens().div(rate);
    }
    
    function canIBuy() public view returns (bool res)
    {
        res = now > start && now < saleEnd() &&  token.getAgent() == address(this) && Max2SpendWei()>0 && VersionSelector(selector).curInvestmentsStorageAddress()!=0;
    }
    
    function sold() public view returns (uint) { return saleTokenLimit.sub(token.getAgentBalance()); }
    
    
    function Sale(address _versionSelectorAddress) WithVersionSelector(_versionSelectorAddress) public {
        //получаем адрес токена от селектора
        token = WithSaleAgent(VersionSelector(_versionSelectorAddress).curAPLXTokenAddress());//token=new SimpleAPXToken()
        require(address(token) != 0x0);
       
        
    }

    
    function() external payable {
             buyTokens();
            }

   
    modifier canBuy() {
        require(canIBuy());
        _;
    }

    function killme() public onlyOwner {
            selfdestruct(owner());
        }
}

contract PreSale is Sale {
  
    function PreSale(address _versionSelectorAddress) Sale(_versionSelectorAddress) public {
        stagenum=0;
        selector = VersionSelector(_versionSelectorAddress);
        multisig = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
       
        rate = 1000;
        start = 1517868326;
        period = 30;
        saleTokenLimit = 1000000 * 1 ether;
        //test saleTokenLimit = 2000 * 1 ether;
        
    }

   uint presaleBonusPercent=40;
   
    
    function finalizeSale() public onlyOwner  returns (bool res)
    {
        if (now > saleEnd())
        {
           token.burnAllOfAgent();
           res=true;
        }
        
        if (Max2SpendWei()<1) //меньше rate за 1 wei не купишь, такие значения могут оставаться после расчета процентов, поэтому их просто сжигаем  (напоминаю 1 токен на счету - это balances[address]==1*10^18)
        {
            token.burnAllOfAgent();
            res=true;
        }
        res=false;
    }
    
    
    
    function Max2BuyTokens() public view returns (uint max2buy)
    {
       uint max = myBalance().mul(100).div(presaleBonusPercent.add(100));
       max2buy=max.div(rate).mul(rate);
    }
    
    

    function buyTokens() public canBuy payable  {
        
        
        
        uint tokens = rate.mul(msg.value);
        
        uint bonus;
        bonus = tokens.mul(presaleBonusPercent).div(100);
         
        uint bonused = tokens.add(bonus);
       
        uint totaltokens=bonused;
        require( totaltokens <= myBalance());
        multisig.transfer(msg.value);
        
        VersionSelector vs=VersionSelector(selector);
        InvestmentsStorage ist = InvestmentsStorage(vs.curInvestmentsStorageAddress());
        ist.AddWei(msg.sender, msg.value , stagenum);
        
       
        token.transferFromAgent(msg.sender, bonused); 
       
        
    }   
}

contract MainSale is Sale {
  
    function MainSale(address _versionSelectorAddress) Sale(_versionSelectorAddress) public {
        stagenum=1;
        selector = VersionSelector(_versionSelectorAddress);
        multisig = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
        restricted = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        bounty = 0x583031D1113aD414F02576BD6afaBfb302140225;
        restrictedPercent = 15;
        bountyPercent=10;
        rate = 1000;
        start = 1519761460;
        period = 30;
        saleTokenLimit = 25000000 * 1 ether;
        
    }

   
    
    function Max2BuyTokens() public view returns (uint max2buy)
    {
        uint balance=myBalance();
        
       
        uint tpercent=0;
        
        if (now.sub(start) < 3 weeks)
        {
            tpercent=5; //если 3 неделя, то 5%
        }
        
        
        if (now.sub(start) < 2 weeks)
        {
            tpercent=10; //если 2 неделя, то 10%
        }
        
        
        if (now.sub(start) < 1 weeks)
        {
            tpercent=15; //если 1 неделя, то 15%
        }
        
        
        if (now.sub(start) < 1 days)
        {
            tpercent=20; //если 1 день, то 20%
        }
        
        uint percent=restrictedPercent.add(bountyPercent);
        
        uint maxwei=1000 ether;
        uint maxbonused=maxwei.mul(rate).mul(tpercent.add(20)).div(100);
        uint total=maxbonused.add(maxbonused.mul(percent).div(100));
        uint lastBuyerPercent=tpercent.add(20);
        uint max;
        if (total<=balance)
        {
             max = myBalance().mul(10000).div(percent.mul(100).add(lastBuyerPercent.mul(100)).add(percent.mul(lastBuyerPercent)).add(10000));
             max2buy=max.div(rate).mul(rate);
             return;
        }
        
        maxwei=100 ether;
        maxbonused=maxwei.mul(rate).mul(tpercent.add(15)).div(100);
        total=maxbonused.add(maxbonused.mul(percent).div(100));
        lastBuyerPercent=tpercent.add(15);
        if (total<=balance)
        {
             max = myBalance().mul(10000).div(percent.mul(100).add(lastBuyerPercent.mul(100)).add(percent.mul(lastBuyerPercent)).add(10000));
             max2buy=max.div(rate).mul(rate);
             return;
        }
        
        maxwei=10 ether;
        maxbonused=maxwei.mul(rate).mul(tpercent.add(10)).div(100);
        total=maxbonused.add(maxbonused.mul(percent).div(100));
        lastBuyerPercent=tpercent.add(10);
        if (total<=balance)
        {
             max = myBalance().mul(10000).div(percent.mul(100).add(lastBuyerPercent.mul(100)).add(percent.mul(lastBuyerPercent)).add(10000));
             max2buy=max.div(rate).mul(rate);
             return;
        }
        
        maxwei=1 ether;
        maxbonused=maxwei.mul(rate).mul(tpercent.add(5)).div(100);
        total=maxbonused.add(maxbonused.mul(percent).div(100));
        lastBuyerPercent=tpercent.add(5);
        if (total<=balance)
        {
             max = myBalance().mul(10000).div(percent.mul(100).add(lastBuyerPercent.mul(100)).add(percent.mul(lastBuyerPercent)).add(10000));
             max2buy=max.div(rate).mul(rate);
             return;
        }
        
        lastBuyerPercent=tpercent;
        
        max = myBalance().mul(10000).div(percent.mul(100).add(lastBuyerPercent.mul(100)).add(percent.mul(lastBuyerPercent)).add(10000));
        max2buy=max.div(rate).mul(rate);
    }
   
    
   
 

    function buyTokens() public canBuy payable {
      
        uint tokens = rate.mul(msg.value);
      
        uint qbonus=0;
        
        if (msg.value >= 1 ether)
        {
            qbonus = tokens.div(20); //если потратили более 1 эфир, то + 5%
        }
        
        if (msg.value >= 10 ether)
        {
            qbonus = tokens.div(10);//если потратили более 10 эфир, то + 10%
        }
        
        if (msg.value >= 100 ether)
        {
            qbonus =  tokens.mul(15).div(100); //если потратили более 100 эфир, то + 15%
        }
        
        if (msg.value >= 1000 ether)
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
        uint bountyTokens = bonused.mul(bountyPercent).div(100);
        uint totaltokens=bonused.add(restrictedTokens).add(bountyTokens);
        require( totaltokens <= myBalance());
        multisig.transfer(msg.value);
        
        VersionSelector vs=VersionSelector(selector);
        InvestmentsStorage ist = InvestmentsStorage(vs.curInvestmentsStorageAddress());
        ist.AddWei(msg.sender, msg.value , stagenum);
        
        token.transferFromAgent(restricted, restrictedTokens);
        token.transferFromAgent(bounty, bountyTokens);
        token.transferFromAgent(msg.sender, bonused); 
        

    }
    
    function finalizeSale() public onlyOwner returns (bool res)
    {
        if (now > saleEnd())
        {
           token.burnAllOfAgent();
           res=true;
        }
        
        if (Max2SpendWei()<1) //меньше rate за 1 wei не купишь, такие значения могут оставаться после расчета процентов, поэтому их просто сжигаем  (напоминаю 1 токен на счету - это balances[address]==1*10^18)
        {
            token.burnAllOfAgent();
            res=true;
        }
        res=false;
    }
}

contract MainSale2 is Sale {
  
    function MainSale2(address _versionSelectorAddress) Sale(_versionSelectorAddress) public {
        stagenum=2;
        selector = VersionSelector(_versionSelectorAddress);
        multisig = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
        restricted = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        bounty = 0x583031D1113aD414F02576BD6afaBfb302140225;
        restrictedPercent = 15;
        bountyPercent=10;
        rate = 1000;
        start = 1515319200;
        period = 28;
        saleTokenLimit = 15000000 * 1 ether;
    }

    function Max2BuyTokens() public view returns (uint max2buy)
    {
       uint max = myBalance().mul(100).div(restrictedPercent.add(bountyPercent).add(100));
       max2buy=max.div(rate).mul(rate); //обнуляем остаток
    }
    

    function buyTokens() public canBuy  payable
    {
        
        uint tokens = rate.mul(msg.value);
       
        uint restrictedTokens = tokens.mul(restrictedPercent).div(100);
        uint bountyTokens = tokens.mul(bountyPercent).div(100);
        uint totaltokens=tokens.add(restrictedTokens).add(bountyTokens);
        require( totaltokens <= myBalance());
        multisig.transfer(msg.value);
        
        VersionSelector vs=VersionSelector(selector);
        InvestmentsStorage ist = InvestmentsStorage(vs.curInvestmentsStorageAddress());
        ist.AddWei(msg.sender, msg.value , stagenum);
        
        token.transferFromAgent(restricted, restrictedTokens);
        token.transferFromAgent(bounty, bountyTokens);
        token.transferFromAgent(msg.sender, tokens); 
       
    }
    
    function finalizeSale() public onlyOwner returns (bool res)
    {
        if (now > saleEnd())
        {
           token.burnAllOfAgent();
           res=true;
        }
        
        if (Max2SpendWei()<1) //меньше rate за 1 wei не купишь, такие значения могут оставаться после расчета процентов, поэтому их просто сжигаем  (напоминаю 1 токен на счету - это balances[address]==1*10^18)
        {
            token.burnAllOfAgent();
            res=true;
        }
        
        //проверка софткапа и организация возврата
        //....
        //res = true;
        //...
        res=false;
       
    }
}


