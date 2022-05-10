// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract NFTContract {
    uint256 public id;

    struct NFT {
        uint256 id;
        string name;
        uint256 cost;
        address owner;
    }

    mapping(uint=> NFT) public nftMapping;

    function mint(string memory _name, uint256 _cost) public {
        nftMapping[id] = NFT(
            id,
            _name,
            _cost,
            msg.sender
        );

        id++;

    }

    function deleteNFT(uint256 _id) public {

        address _owner = nftMapping[_id].owner;
        require(_owner != address(0), "This NFT doesn't exist!");
        require(_owner == msg.sender, "Only Owner can delete the NFT!");

        nftMapping[_id] = NFT(
            0,
            "",
            0,
            address(0)
        );

    }

    function updateNFT(uint256 _id, string memory _name, uint256 _cost) public {
        address _owner = nftMapping[_id].owner;
        require(_owner != address(0), "This NFT doesn't exist!");
        require(_owner == msg.sender, "Only Owner can update the NFT!");

        nftMapping[_id] = NFT(
            _id,
            _name,
            _cost,
            msg.sender
        );
    }



}
