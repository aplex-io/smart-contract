pragma solidity ^0.4.20;

import 'browser/IVersionSelector.sol';


/**
* �������� ������������ ��� �������� ������ ���������,
* ������� ����� ������ �� ��� ��������� ������� - VersionSelector
*/
contract WithVersionSelector
{
    //�������� IVersionSelector
    IVersionSelector internal selector;
    
    //�����������
    //@param _selector ����� ��������� IVersionSelector 
    function WithVersionSelector(address _selector) public {
        require(_selector != 0x0);
        selector=IVersionSelector(_selector);
    }
}
