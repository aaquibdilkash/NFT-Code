// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract NFTContract {
    uint256 private id;

    struct NFT {
        uint256 id;
        string name;
        uint256 cost;
        address owner;
        bool onAuction;
        address[] biddersList;
    }

    mapping(uint256 => mapping(address => uint256)) biddersMap;

    mapping(uint256 => NFT) public nftMapping;


    // mint NFT
    function mintNFT(string memory _name, uint256 _cost) public {
        nftMapping[id].id = id;
        nftMapping[id].name = _name;
        nftMapping[id].cost = _cost;
        nftMapping[id].owner = msg.sender;

        id++;
    }


    // delete NFT
    function deleteNFT(uint256 _id) public {
        address _owner = nftMapping[_id].owner;
        require(nftMapping[_id].onAuction == false, "This NFT is currently on Auction!");
        require(_owner != address(0), "This NFT doesn't exist!");
        require(_owner == msg.sender, "Only Owner can delete the NFT!");

        nftMapping[id].name = "";
        nftMapping[id].cost = 0;
        nftMapping[id].owner = address(0);
    }

    // update NFT
    function updateNFT(
        uint256 _id,
        string memory _name,
        uint256 _cost
    ) public {
        address _owner = nftMapping[_id].owner;
        require(_owner != address(0), "This NFT doesn't exist!");
        require(_owner == msg.sender, "Only Owner can update the NFT!");

        nftMapping[_id].name = _name;
        nftMapping[_id].cost = _cost;
    }


    // put item for auction --> only owner
    function putUpForAuction(uint256 _id) public {
        address _owner = nftMapping[_id].owner;
        require(_owner != address(0), "This NFT doesn't exist!");
        require(_owner == msg.sender, "Only Owner can update the NFT!");

        nftMapping[_id].onAuction = true;
    }


    // To make a bid for Auction
    function makeBidForAuction(uint256 _id) public payable {
        address _owner = nftMapping[_id].owner;
        require(_owner != address(0), "This NFT doesn't exist!");
        require(_owner != msg.sender, "You can't bid on owned NFT!");
        require(
            nftMapping[_id].onAuction == true,
            "This NFT is not currently on Auction!"
        );
        require(
            biddersMap[_id][msg.sender] == 0,
            "You already have an existing bid!"
        );

        biddersMap[_id][msg.sender] = msg.value;
        nftMapping[_id].biddersList.push(msg.sender);
    }


    // To withdraw the bid for auction
    function withdrawBidForAuction(uint256 _id) public {
        address _owner = nftMapping[_id].owner;
        require(_owner != address(0), "This NFT doesn't exist!");
        require(
            nftMapping[_id].onAuction == true,
            "This NFT is not currently on Auction!"
        );
        require(
            biddersMap[_id][msg.sender] != 0,
            "You don't have an existing bid!"
        );

        payable(msg.sender).transfer(biddersMap[_id][msg.sender]);
        biddersMap[_id][msg.sender] = 0;

        // set the bid amount of withdrawer to 0 and remove him from biddersList
        for (uint256 i = 0; i < nftMapping[_id].biddersList.length; i++) {
            if (nftMapping[_id].biddersList[i] == msg.sender) {
                nftMapping[_id].biddersList[i] = address(0);
            }
        }
    }

    // To end the auction --> only owner
    function endAuction(uint256 _id) public {
        address _owner = nftMapping[_id].owner;
        require(_owner != address(0), "This NFT doesn't exist!");
        require(_owner == msg.sender, "Only Owner can update the NFT!");
        require(
            nftMapping[_id].onAuction == true,
            "This NFT is not currently on Auction!"
        );

        address highestBidder = address(0);
        uint256 highestBid = 0;

        // find the highest bid and highest bidder
        for (uint256 i = 0; i < nftMapping[_id].biddersList.length; i++) {
            if (nftMapping[_id].biddersList[i] != address(0) && biddersMap[_id][nftMapping[_id].biddersList[i]] > highestBid) {
                highestBidder = nftMapping[_id].biddersList[i];
                highestBid = biddersMap[_id][highestBidder];
            }
        }

        // transfer back the amount to those who didn't win the auction
        for (uint256 i = 0; i < nftMapping[_id].biddersList.length; i++) {
            if (
                nftMapping[_id].biddersList[i] != highestBidder &&
                nftMapping[_id].biddersList[i] != address(0)
            ) {
                payable(nftMapping[_id].biddersList[i]).transfer(
                    biddersMap[_id][nftMapping[_id].biddersList[i]]
                );
                biddersMap[_id][nftMapping[_id].biddersList[i]] = 0;
            }
        }

        // pay the owner
        if(highestBid > 0) {
            payable(_owner).transfer(highestBid);
            // highestBidder is the new owner
            nftMapping[_id].owner = highestBidder;
        }

        nftMapping[_id].onAuction = false;
        delete nftMapping[_id].biddersList;
    }
}
