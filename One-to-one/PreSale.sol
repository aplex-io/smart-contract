pragma solidity ^0.4.20;

import 'browser/Ownable.sol';
import 'browser/InvestmentsStorage.sol';
import 'browser/Sale.sol';


/**
* �������� ������ ������� ������� APLX. �������� ������ �� ���� ���� � ������
* �� � ������ �������� ����� ICO - PreICO .
* ���������� �������� ��������������� ����������� �� ���� ��������� ���������� 
* ������������� InvestmentsStorage � �� ����� ���� ���������� ���������. 
* �������� InvestmentsStorage, � ���� �������, ��������������� ��������� 
* ���������� �� ����� ������ �������� ���� APLEX.
*/
contract PreSale is Sale 
{
    //�����������
    function PreSale(address _versionSelectorAddress) Sale(_versionSelectorAddress) public 
    {
        //����� �����
        stagenum=0;
        
        //���������� �������, ����������� �� 1 Ether
        //��������! ��� rate = 1 � ������� 1 APLX �� 1 Ether
        //������ ��������� ���������� �� 1 * 10^18, �.�. decimals == 18
        rate = 1000;
        
        //����� ������
        start = 1517868326;
        
        //����������������� ����� � ����
        period = 30;
        
        //���������� �������, ������� �������� ����� ��� �������
        saleTokenLimit = 1000000 * 1 ether;
        //test saleTokenLimit = 2000 * 1 ether;
        
    }
    
    //������� ������� ������������ ���������� ����������� �� ���������� ���������� �� ����� preICO
    uint presaleBonusPercent=40;
   
    //������� ��������� ������� ������� ������� 
    function finalizeSale() public onlyOwner  returns (bool)
    {
        //���� ������� ����� ������ ������� ���������
        if (now > saleEnd())
        {
           //������� �������
           token.burnAllOfAgent();
           return true;
        }
        
        //���� ������ ��������� (�������� < rate * 10^-18 )
        if (Max2SpendWei()<1) //������ rate �� 1 wei �� ������, ����� �������� ����� ���������� ����� ������� ���������, ������� �� ������ �������  (��������� 1 ����� �� ����� - ��� balances[address]==1*10^18)
        {
            //������� �������
            token.burnAllOfAgent();
            return true;
        }
        return false;
    }
    
    
     //���������� ������������ ���������� �������, ��������� � �������
    function Max2BuyTokens() public view returns (uint max2buy)
    {
      //��������� ���������� ������*100/140%)
       uint max = myBalance().mul(100).div(presaleBonusPercent.add(100));
       //�������� �������
       max2buy=max.div(rate).mul(rate);
    }
    
     
     //������� ������� �������
    function buyTokens() public canBuy payable  
    {
        //���������� ���������� �������
        uint tokens = rate.mul(msg.value);
        
        //���������� �������� �������
        uint bonus;
        bonus = tokens.mul(presaleBonusPercent).div(100);
        
        //����� ���������� ��������� 
        uint totaltokens=tokens.add(bonus);
        
        //��������� ���� �� �������
        require( totaltokens <= myBalance());
          
        //�������� InvestmentsStorage
        InvestmentsStorage ist = InvestmentsStorage(selector.investmentsStorage());
        //���������� �������� � investmentsStorage � ��������� ����������� 
        //� ������ ����� 
        ist.AddWei.value(msg.value)(msg.sender, stagenum);
        //��������� ������ ����������
        token.transferFromAgent(msg.sender, totaltokens); 
    }   
}