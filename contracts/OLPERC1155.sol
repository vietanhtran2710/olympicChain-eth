// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./OLPAccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract OLPERC1155 is
    ERC1155,
    ERC1155Holder,
    OLPAccessControl
{
    address public ownerAddress;
    uint256 private _currentTokenId = 2;
    uint256 public constant KNG_ID = 0;
    uint256 public constant VNH_ID = 1;

    mapping(uint256=>string) private _uris;
    mapping(address=>uint256) private nftCount;

    constructor() ERC1155("") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(URI_SETTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        ownerAddress = _msgSender();

        //Temporarily mint initial supply to defaul admin.
        //_mint(_msgSender(), KNG_ID, 10**18, "");
        //_mint(_msgSender(), VNH_ID, 10**11, "");
    }

    function createNFT(address _owner, string memory _uri)
        public
        returns (uint256)
    {
        require(
            isAdmin(_msgSender()) || isSponsor(_msgSender()) || isTeacher(_msgSender()) || isParent(_msgSender()),
            "OLPERC1155: can only create new NFT if sender is Admin, Sponsor, Teacher or Parent"
        );
        _mint(_owner, _currentTokenId, 1, "");
        setTokenUri(_currentTokenId, _uri);
        nftCount[_owner] += 1;
        _currentTokenId++;

        return _currentTokenId;
    }

    function mintKNG(address _account, uint256 _amount, bytes memory data) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(_account, KNG_ID, _amount, data);
    }

    function mintVNH(address _account, uint256 _amount, bytes memory data) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(_account, VNH_ID, _amount, data);
    }

    function burnVNH(address _account, uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(_account, VNH_ID, _amount);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function approveForContract() public {
        setApprovalForAll(PROCESS_CONTRACT_ADDRESS, true);
    }

    function withdrawFromContract(address _to, uint256 _id, uint256 _amount, bytes memory data) public onlyRole(PROCESS_CONTRACT_ROLE) {
        OLPERC1155(address(this)).safeTransferFrom(address(this), _to, _id, _amount, data);
    }

    function withdrawBatchFromContract(address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory data) public onlyRole(PROCESS_CONTRACT_ROLE) {
        OLPERC1155(address(this)).safeBatchTransferFrom(address(this), _to, _ids, _amounts, data);
    }

    function uri(uint256 _tokenId) override public view returns(string memory) {
        return(_uris[_tokenId]);
    }

    function setTokenUri(uint256 _tokenId, string memory _uri) private {
        _uris[_tokenId] = _uri;
    }

    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal override(ERC1155) onlyRole(MINTER_ROLE) {
        super._mint(account, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155) onlyRole(MINTER_ROLE) {
        super._mintBatch(to, ids, amounts, data);
    }

    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal override(ERC1155) {
        super._burn(account, id, amount);
    }

    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal override(ERC1155) {
        super._burnBatch(account, ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl, ERC1155Receiver)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getOwnedNFTs(address owner) public view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 2; i < _currentTokenId; i++) {
            if (balanceOf(owner, i) == 1) {
                count++;
            }
        }
        uint256[] memory nfts = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < _currentTokenId; i++) {
            if (balanceOf(owner, i) == 1) {
                nfts[index] = i; index++;
            }
        }
        return nfts;
    }
}
