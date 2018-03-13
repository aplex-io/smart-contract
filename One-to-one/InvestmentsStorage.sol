pragma solidity ^0.4.20;


import 'browser/WithVersionSelector.sol';
import 'browser/BasicToken.sol';
import 'browser/SafeMath.sol';


/**
* �������� ������������ ��� ���������� ����������,
* ������������ � ���� �������� ICO (preICO).
* 
* ����� ������ ��������� ����������� ��� �������� 
* �� ���� ��������� InvestmentsStorage.
* 
* InvestmentsStorage ��������� �������� �� ���� APLEX ������ � ���� �������:
* 1) �� ����� preICO (��� �������� ����������� ����������� ����������� � ������
*    ������, �.�.  �� ����� ���� ����������. ��� ���� ��������� ��������
*    ������������ ���������� �� ���� ������);
* 2) ��� ���������� ������� ��������.
* 
* InvestmentsStorage ��������� ��������� �������������� ������� ���������
* �������� ����� ��������� ICO, ���� �� ���������� ������� ��������, �����������
* ������ ������� WithdrawMyInvestments �� ���� (������� �� ���) ���������. �����
* ��������� ������� �������� ������ �������������� ����� ��� ������ APLX,
* ����������� ��� ����� ��� ���������� ������� ����� �� ������������� �������.
*/
contract InvestmentsStorage is WithVersionSelector
{
    using SafeMath for uint;
    
    //������� ����� ��������� -> ���������� ��������� ������� � wei
    mapping(address => uint256) investor2wei;
    
    //��������� ���������� ��������� ������� � wei �� ������ investor
    function investmentOf(address investor) public constant returns (uint256 balance)
    {
        balance = investor2wei[investor];
    }
    
    //���������� �������, ���������� �� ����� preSale
    uint public presalewei=0;
    
    //���������� �������, ���������� �� ����� MainSale
    uint public mainsalewei=0;
    
    //���������� �������, ���������� �� ����� MainSale2
    uint public mainsale2wei=0;
    
    //������� ������� - ��� ���������� ��� �������� ����������� �� ���� APLEX
    uint public constant softcap=8000 * 1 ether;
    
    //���������� ������ ������� 
    bool public blockWithdraw = true;
    
    //���������� �������, ����������� �� ���� APLEX
    uint public transferred2Multisig=0;
    
    //��������� ������� ������� �� ���� APLEX ����� preSale � �� ����������
    //�������
    bool public stage0ended=false;
    
    
    //����� ����� APLEX
    address constant multisig=0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
    
    
    //�����������
    function InvestmentsStorage(address _versionSelectorAddress) WithVersionSelector(_versionSelectorAddress) public
    {
    
    }
    
    //fallback �������
    function() public payable 
    {
        //��� ������ ������ �������� ����������� �� ���� APLEX
        multisig.transfer(msg.value);
        transferred2Multisig.add(msg.value);
    }
    
    //���������� ������ ��������� InvestmentsStorage
    function  getBalance() public view returns(uint)
    {
        return this.balance;
    }
    
    //��������� ����� ���������� �������, ���������� �� 3 ����� ICO
    function GetTotalInvestments() public view returns(uint) {
        return presalewei.add(mainsalewei).add(mainsale2wei);
    }
    
    //������� (��������� ether) ���������� �������� ������� ��� �������� ������� APLX
    function AddWei(address investor,  uint stagenum) payable public 
    {
        //������ ���������� ������� �������
        require(msg.value>0 && address(selector)!=0 && msg.sender==address(selector.curSaleAgentAddress()));
        
        //������� stage0ended==false �����������, ����� ���������
        //���������� presalewei � ��� ����� � GetTotalInvestments �� 
        //����� �������� ���� �������� ������ � ������������� 
        //������ ����� ���� addwei � stagenum==0,
        //������� ����� � ���������� ������
        if (stagenum==0 && stage0ended==false)
        {
            //preICO
            
            //����������� �������� ������ �� ����
            presalewei=presalewei.add(msg.value);
            
            //��������� �� ����� APLEX
            multisig.transfer(msg.value);
            
            //����������� ����� ����������� �������
            transferred2Multisig.add(msg.value);
            
            //�� ��������� Investors2wei!!!
        }
        else if (stagenum==1)
        {
            //MainSale
            
            //���� ������� 1 ����, �� ��������� ���� preICO (��. ����)
            if (!stage0ended)
            {
                stage0ended=true;
            }
            
            //����������� �������� ������ �� ����
            mainsalewei=mainsalewei.add(msg.value);
            
            //����������, ������� ������ ��������
            investor2wei[investor]=investor2wei[investor].add(msg.value);
        }
        else if (stagenum==2)
        {
            //MainSale2
    
            //����������� �������� ������ �� ����
            mainsale2wei=mainsale2wei.add(msg.value);
            
            //����������, ������� ������ ��������
            investor2wei[investor]=investor2wei[investor].add(msg.value);
        }
        else
        {
            //��������� ����������� ��������� ������,
            //������� ����� ������������ storage � ������������� �� multisig
            //������ ��� ��� ������ � Investors2wei � ����� �������� �����������
            //������ ������� ����������� ������ MainSale �  MainSale2 ��� 
            //������������ ��������
            
            //������� �� ���� APLEX
            multisig.transfer(msg.value);
            transferred2Multisig.add(msg.value);
        }
        
        
        //������� ���� ������� �� ���� APLEX �� ���������� ��������
        if (GetTotalInvestments()>=softcap)
        {
            TranferAll2Multisig();
        }
    }
    
    //������� ���� ������� �� ���� APLEX
    function TranferAll2Multisig() private
    {
        uint val=this.balance;
        multisig.transfer(val);
        transferred2Multisig.add(val);
    }
    
    //�������� ���������� ����� ICO (���������� �� VersionSelector)
    //��������� ������� ������� � ��������� ��� �������� �� ���� 
    //APLEX (��� ����������), ���� ������������ ������� � ��������� ������
    function finalizeLastStage() public
    {
        //�������� VS
        require(address(selector)!=0 && msg.sender==address(selector));
        
        //�������� ������� ��������
        if (GetTotalInvestments()<softcap)
        {
            //�������������
            blockWithdraw=false;
        }
        else
        {
            //������� �� ���� APLEX
            //�� ����� � ���� ������ �� ���
            //������ ���� ���������� �� ���� APLEX
            TranferAll2Multisig();
        }
    }
    
    //������� ������ ������� ��� ������������ ��������
    function WithdrawMyInvestments() public
    {
        //�������� ����������
        require(!blockWithdraw);
       
        uint bal=0;
        
        //���� VS �� ��� �������� ����� ������ APLX
        if (selector.curAPLXTokenAddress()!=0)
        {
            //�������� ������ ��������� � ������� APLX
            bal=BasicToken(selector.curAPLXTokenAddress()).balanceOf(msg.sender);
        }
        
        //���� ������� � ��������� ���
        require(bal==0);
        
        //�������� ���������� ��������������� �������
        uint val=investor2wei[msg.sender];
        
        //�������� ���������� ��������������� �������
        investor2wei[msg.sender]=0;
        
        //��������� ���������
        msg.sender.transfer(val);
    }
}