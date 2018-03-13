pragma solidity ^0.4.20;

import 'browser/IVersionSelector.sol';


/**
*  онтракт предназначен дл€ хранени€ адреса контракта,
* который имеет ссылки на все контракты системы - VersionSelector
*/
contract WithVersionSelector
{
    // онтракт IVersionSelector
    IVersionSelector internal selector;
    
    // онструктор
    //@param _selector адрес контракта IVersionSelector 
    function WithVersionSelector(address _selector) public {
        require(_selector != 0x0);
        selector=IVersionSelector(_selector);
    }
}
