pragma solidity ^0.4.20;

import 'browser/WithSaleAgent.sol';
import 'browser/BurnableToken.sol';
import 'browser/ExchangableFromAPLX.sol';

/**
* �������� ������ APLX. ������������� ��� 
* ����� ������� � ���� ���������� ������� �� ICO (preICO)
* 
* BurnableToken - ��������� utility ����� ERC20 � ������������� ��������
* WithSaleAgent - ��������� ������� �������� ������� ���������� APLEX ICO
*/
contract APLXToken is BurnableToken, WithSaleAgent {

    //�������� ������
    string public constant name = "APLEX Token";

    //�������� �������� ������
    string public constant symbol = "APLX";
    
    //���������� �������� - ��������, ��� 
    //�����, �� ����� �������� ������� 1 APLX
    //����� ������ 1 * 10^18 � ������� ������ balances
    uint32 public constant decimals = 18;
    
    //���������� ����������� �������
    uint256 public constant initial_supply = 41000000 * 1 ether;
    
    //�����������
    function APLXToken(address _selector) WithSaleAgent(_selector)  public {
        totalSupply = initial_supply;
        balances[msg.sender] = initial_supply;
    }
    
    //������� �������� �� ����� APLC � ��������� APLX
    function BurnWithExchange(uint amount) public
    {   
        //�������� ����� ������ ���������� ������, ��� ����������� ���������� APLX �� ����� 
        //���������, ���������� �������, ��� ������������ ������ ��������� ������ APLC � VS 
        require(!blockExchange && balances[msg.sender]>=amount && selector.curAPLCTokenAddress() != address(0));
        
        //������� �������
        burn(amount);
        
        //�������� ����� ������ APLC
        ExchangableFromAPLX exto=ExchangableFromAPLX(selector.curAPLCTokenAddress());
        
        //��������� APLC �� ����� ������������
        exto.MintForExchange(msg.sender, amount);
    }
 
    //��������� �������� ������� ������
    function getAgentBalance() public view returns (uint agentbalance)
    {
        require(saleAgent!=0x0);
        return balances[saleAgent];
    }
     
    //������� ������� �� ����� ������ (������ �����)
    function transferFromAgent(address _to, uint _value) public isSaleAgent returns (bool) {
        require(_to != 0x0);
        return transfer(_to, _value);
    } 
   
    //������� ������� �� ���� ������ (������ ��������)
    function transferToAgent(uint _value) public onlyOwner returns (bool) {
        require(saleAgent != 0x0);
        
        return transfer(saleAgent, _value);
    }
    
    
    //�������� ����������� �������� ������� ����� �������
    function ValidateTransfer() public view returns(bool)
    {
        //��������� � ������ ������� (��� ����������� � ������� � VS)  ����� ������
        if (msg.sender==owner || (address(selector) != 0 && selector.curSaleAgentAddress()==saleAgent && msg.sender==saleAgent))
            return true; 
        
        //���� ICO �� ���������, �� ������    
        if (endSales == 0)
            return false;
        else
        {
            //�����, ���� ������� ����� ������ ��� ��, ������� ��������� ����
            //�� ������� ��������� ICO ��������� �����, �� ������� 
            //����������� ���������� ��� ������ �����������
            //(���� ���������� �� �����������, �� ������� ����� ����� ������
            //endSales � �������� �������� )
            return endSales.add(blocked[msg.sender]) < now;
        }
         
    }
    
    //������� �� ������� ����� ����������� �� ����� _to � ���������� _value 
    function transfer(address _to, uint _value) public  returns (bool)
    {
        //�������� ���������� ��������
        require(ValidateTransfer());  
        //�������
        return super.transfer(_to,  _value);
    }
    
    //�������� ���� ������� ������ (������ �����)
    function burnAllOfAgent() public isSaleAgent
    {
        //���� ����, ��� �������
        if (getAgentBalance()>0)
            burn(balances[saleAgent]);
    }
}