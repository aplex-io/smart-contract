pragma solidity ^0.4.20;

import 'browser/WithVersionSelector.sol';
import 'browser/MintableToken.sol';

/**
* �������� �������������� ������ ������� ��� ������ APLX �� APLC
* �� ���� ��������� 
*/
contract ExchangableFromAPLX is MintableToken, WithVersionSelector
{
    using SafeMath for uint;
    
    //�����������
    function ExchangableFromAPLX(address _versionSelectorAddress) public WithVersionSelector(_versionSelectorAddress)
    {
        
    }
    
    //������ ������� ��� ������ APLX �� APLC �� ���� ��������� (holder) 
    //� ���������� � amount
    //������� ���������� ������� APLX
    function MintForExchange(address holder, uint amount)  public
    {
        //��������, ��� ������� ���������� ������� APLX
        require(address(selector)!=0x0 && selector.curAPLXTokenAddress()==msg.sender);
        //������������� ������ ���������� ���������� �������
        totalSupply = totalSupply.add(amount);
        //������ �� ���� holder-�
        balances[holder] = balances[holder].add(amount);
        //������� Mint
        Mint(holder, amount);
        //������� Transfer (0->holder)
        Transfer(address(0), holder, amount);
    }
}