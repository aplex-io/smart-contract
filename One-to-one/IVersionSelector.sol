pragma solidity ^0.4.20;

/**
* ������ ��������� ������,�� ��������� ����� ������ �����
* �����, ����������, ������� �������� �������� c ����� ���������
* � ��������� ������� ���������� ����������. � ����� ����� � ������ ��������� 
* �� ������ ������ ���� ������������ � ������� ���������� ������ �����
* ��� ���������� ������� ���������� ������� ������� �� ������������ ����������� 
* ������ ������ ����������, ����� ������������� ����������� ������� �������
* 
* ������ �������� �������� ����������� � ��������� ����������� 
* ���������� � ��������� VersionSelecor, ����������� ��� ����������������
* � ������� ������� ������� APLEX
*/
contract IVersionSelector  {
    //����� ������ APLX
    address public curAPLXTokenAddress;
    
    //����� ������ APLC
    address public curAPLCTokenAddress;
    
    //����� ��������� ������� (���� �� ������������)
    address public curMarketAddress;
    
    //����� �������� ������ ����������
    address public curSaleAgentAddress;
    
    //����� ���������, ����������� ���������� � ������������ ���
    address public investmentsStorage;

    //��������� ������ ��������� ������� (���� �� ������������) 
    function setCurMarketAddress(address _newaddr)  public ;
    
    //��������� ������ ��������� ������ APLX
    function setCurAPLXTokenAddress(address _newaddr)  public ;
    
    //��������� ������ ��������� ������ APLC   
    function setCurAPLCTokenAddress(address _newaddr)  public ;
    
    //��������� ������ �������� ������ �������
    function setCurSaleAgentAddress(address _newaddr)  public ;
  
    //������ ���������� ������ APLX �� APLC
    function UnblockExchangeAPLX()  public;
     
    //��������� ������� �������� ������ ������� 
    function getsaleAgentBalance() public view returns(uint agentbal);
  
}