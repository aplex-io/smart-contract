pragma solidity ^0.4.20;

import 'browser/Ownable.sol';
import 'browser/SafeMath.sol';
import 'browser/WithSaleAgent.sol';


/**
* �������� ������ ������� ������� APLX. �������� ������ �� ���� ���� � ������
* �� � ������ ����� ICO. ���������� �������� ��������������� ����������� �� ���� 
* ��������� ���������� ������������� InvestmentsStorage. ��������� �������
* ��������� ���������� �� �������� � �������� � ����������� �� ������ �����.
* 
* ������ �������� �������� ����������� � ��������� ����������� 
* ���������� � ��������� ������ ������� ������� APLX � ������ ICO.
*/
contract Sale is Ownable, WithVersionSelector 
{
    using SafeMath for uint;
    
    //����� �����
    uint8 public stagenum=0;

    //������� ������� ����������� �� ����� APLEX (�������)
    uint restrictedPercent;

   //������� ������� ����������� �� ����� APLEX (bounty)
    uint bountyPercent;
    
    //������� ������� ����������� �� ����� APLEX (������)
    uint reservedPercent;

    //����� APLEX (�������)
    address restricted;
    
    //����� APLEX (������)
    address reserved;
    
    //����� APLEX (bounty)
    address bounty;
    
    //���������� �������, ������� �������� ����� ��� �������
    uint public saleTokenLimit;
    
    //����� ������ ��� �������
    WithSaleAgent public token;
    
    //������� ������� ������� (�����������)
    function buyTokens() public canBuy payable; 
   
    //������� ��������� ������� ������� ������� (�����������)
    function finalizeSale() public returns (bool res);
    
    //����� ������
    uint public start;
    
    //����������������� ����� � ����
    uint public period;

    //���������� �������, ����������� �� 1 Ether
    //��������! ��� rate = 1 � ������� 1 APLX �� 1 Ether
    //������ ��������� ���������� �� 1 * 10^18, �.�. decimals == 18
    uint public rate;
    
    //���������� ����� ��������� �����
    function saleEnd() public view returns (uint) { return start.add(period * 1 days); }
    
    //���������� ������ ������
    function myBalance() public view returns (uint) 
    {
        require(token.getAgent() == address(this));
        return token.getAgentBalance(); 
    }
    
    //���������� ������������ ���������� �������, ��������� � �������
    function Max2BuyTokens() public view returns (uint max2buy);
   
    //���������� ������������ ���������� wei, ��������� � ������
    function Max2SpendWei() public view returns (uint maxwei)
    {
       maxwei = Max2BuyTokens().div(rate);
    }
    
    
    //��������� ����������� �������
    function canIBuy() public view returns (bool res)
    {
        //�������:
        //- ����� ������ ������
        //- ����� ������ ���������
        //- ����� ��������� � ������� ������ ������
        //- ������������ ���������� wei, ��������� � ������ > 0
        //- �������� ����� ��������� InvestmentsStorage
        res = now > start && now < saleEnd() &&  token.getAgent() == address(this) && Max2SpendWei()>0 && address(selector.investmentsStorage())!=0;
    }
    
    //���������� ���������� ��������� ������� (������ � ��������)
    function sold() public view returns (uint)
    {
        return saleTokenLimit.sub(token.getAgentBalance()); 
    }
    
    //�����������
    function Sale(address _versionSelectorAddress) WithVersionSelector(_versionSelectorAddress) public
    {
        //�������� ����� ������ �� ���������
        token = WithSaleAgent(selector.curAPLXTokenAddress());//token=new SimpleAPXToken()
        require(address(token) != 0x0);
    }
    
    //fallback �������
    function() external payable 
    {
        buyTokens();
    }

    //����������� �������� ����������� �������
    modifier canBuy() 
    {
        require(canIBuy());
        _;
    }
        
    //����������� ��������� � ������������� ������� �� ���� ���������
    function killme() public onlyOwner 
    {
        selfdestruct(owner);
    }
}