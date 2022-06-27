// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";


contract JamBook {

    using Counters for Counters.Counter;

    Counters.Counter private currentPosition;

    struct Song {
        string songTitle;
        string songURL;   
        uint playCount; // number of accumulated plays
        address proposer;
        uint songID;
    }

    struct Jam {
        string venue;
        Song[] tracklist;
    }

    Song[] public songs; // all songs ever saved
    Jam[] public allJams; // all Jams ever created

    mapping(uint => Song) public songIndex; // access the song info by its index

    mapping(uint => Jam) public jamsInTime; // access the Jam info by its index

    mapping (address => bool) public ethMusicians; // who is and who is not an EthMusician


    modifier isEthMusician {
        require(ethMusicians[msg.sender] == true, "you are no ethMusician, yet.");
        _;
    }


    constructor(address[] memory _firstPeers) {
        for (uint i = 0; i < _firstPeers.length; i++) {
            address newPeer = _firstPeers[i];
            require(newPeer != address(0), "invalid address");
            ethMusicians[newPeer] = true;
        }

        currentPosition.increment();
    }

    
    // Only and EthMusician can elect another EthMusician

    function addEthMusician(address[] memory _newMusicians) public isEthMusician {
        for (uint i = 0; i < _newMusicians.length; i++) {
            address newMusician = _newMusicians[i];
            require(newMusician != address(0), "invalid address");
            ethMusicians[newMusician] = true;
        }
    }

    
    function saveSong(string memory _songTitle, string memory _songURL) public isEthMusician {
        Song memory song;
        song.songTitle = _songTitle;
        song.songURL = _songURL;
        song.playCount = 0;
        song.proposer = msg.sender;
        song.songID = currentPosition.current();
        songs.push(song);
        songIndex[currentPosition.current()] = song;
        currentPosition.increment();
    }


    function createJam(string memory _venue, uint _date) public isEthMusician {
        Jam memory newJam;
        newJam.venue = _venue;
        jamsInTime[_date] = newJam;
        allJams.push(newJam);

    }

    function pushSongIntoJam(uint _date, uint[] memory _songIDs) public isEthMusician {
        //needs a require that song exists in songs array
        Jam storage newJam = jamsInTime[_date];
        for (uint i = 0; i < _songIDs.length; i++) {
            uint newsongID = _songIDs[i];
            songIndex[newsongID].playCount++;
            newJam.tracklist.push(songIndex[newsongID]);

        }

    }

    function findJamByDate(uint _date) view public returns (Jam memory) {
        return jamsInTime[_date];
    }


    function showAllSongs() public view returns(Song[] memory) {
        return songs;
    }

    function howManySongs() public view returns(uint) {
        return songs.length;
    }
}
