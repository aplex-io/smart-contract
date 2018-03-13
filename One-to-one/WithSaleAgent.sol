pragma solidity ^0.4.20;

import 'browser/WithVersionSelector.sol';
import 'browser/Ownable.sol';


/**
* �������� �������������� ������� ������� �� ����� ������ �������
* (�����������)
*/
contract WithSaleAgent is Ownable, WithVersionSelector {
    
     //����� ������ �������
     address internal saleAgent;
     
     //������� ���������� �������� ������� � �������� ����� ICO
     //���� -�����, �������� - ����� � unix �������, �� ������� 
     //��������������� ���������� ��� ������ (������ �� ��������� ICO -  endsales)
     mapping(address => uint256) blocked;
     
     //UNIX �����, ����� ����������� ICO (������������ ������� ��� �����������)
     uint public endSales=0;
     bool blockExchange=true;
     
     //�����������
     function WithSaleAgent(address _selector) WithVersionSelector(_selector) public {
     
     }
    
    //��������� ������� ���������� ������ ����� ICO ��� ������ blocking �� ����� time (UNIX ������)
    function AddBlockTime(address blocking, uint time) public isSaleAgent
    {
        blocked[blocking]=time;
    }
    
    //��������� ������� ��������� ICO ������� ��� ����������� 
    function setEndSales() public isSaleAgent 
    {
        endSales=now;
    } 
    
    //������������ ������ (APLX �� APLC)
    function UnblockExchange() public onlyOwner
    {
        blockExchange = false;
    }
    
    //����������� - ���������� ������ ������� ��� ����������
    modifier isSaleAgentOrOwner 
    {
         if (msg.sender == owner) //��������
         {
            _;
         }
         else
         {
             require(address(selector)!=0x0 ); //VersionSelector ��������
             require(saleAgent != 0x0 ); //����� �� ������
             require(selector.curSaleAgentAddress() == msg.sender ); //��������� ���������� �� saleAgent � VersionSelector 
             require(msg.sender == saleAgent); //�����
             _;
         }
     }
     
       modifier isSaleAgent 
       {
             require(address(selector)!=0x0 ); //VersionSelector ��������
             require(saleAgent != 0x0 ); //����� �� ������
             require(selector.curSaleAgentAddress() == msg.sender ); //��������� ���������� �� saleAgent � VersionSelector 
             require(msg.sender == saleAgent); //�����
             _;
        }
     
     
     //��������� �������� ������ (������ ��������)
    function setSaleAgent(address newAgent) public onlyOwner returns(bool res) 
    {
         saleAgent = newAgent;
         res = saleAgent == newAgent;
    }
     
    //��������� ������ �������� ������ 
    function getAgent() public view returns (address agent)
    {
        return saleAgent;
    }
    
    //��������� �������� ������� ������
    function getAgentBalance() public view returns (uint agentbalance);
        
    //������� ������� �� ����� ������ (������ �����)
    function transferFromAgent(address _to, uint _value) public returns (bool);
    
    //������� ������� �� ���� ������ (������ ��������)
    function transferToAgent(uint _value) public returns(bool res);
    
    //�������� ���� ������� ������ (������ �����)
    function burnAllOfAgent() public;
}