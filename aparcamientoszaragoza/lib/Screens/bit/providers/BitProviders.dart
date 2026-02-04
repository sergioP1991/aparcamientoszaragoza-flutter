import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;

class BitState extends StateNotifier<AsyncValue<String>> {
  BitState() : super(const AsyncData(""));

  Future<BigInt> getEth(String ethAccount) async {

    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {
      var apiUrl = "http://127.0.0.1:8545/"; //Replace with your API

      var httpClient = Client();
      //var ethClient = Web3Client(apiUrl, httpClient);

      //var credentials = EthPrivateKey.fromHex(ethAccount);
      //EtherAmount balance = await ethClient.getBalance(credentials.address);

     // return "" + balance.getInEther.toString();
      return "";
    });
    return BigInt.zero;
  }

  Future<String> createBit(String ethAccount, String amount) async {

    // set the loading state
   /* state = const AsyncLoading();

    String privateKey = ethAccount;
    final EthereumAddress contractAddr =
    EthereumAddress.fromHex('0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512');

    var apiUrl = "http://127.0.0.1:8545/"; //Replace with your API
    var httpClient = Client();
    var ethClient = Web3Client(apiUrl, httpClient);
    final credentials = EthPrivateKey.fromHex(privateKey);
    //final ownAddress = await credentials.extractAddress();
    final chainID = await ethClient.getChainId();
    const String abiCode = ""
        "[\n\t{\n\t\t\"inputs\": [\n\t\t\t{\n\t\t\t\t\"internalType\": \"uint256\",\n\t\t\t\t\"name\": \"_biddingTime\",\n\t\t\t\t\"type\": \"uint256\"\n\t\t\t}\n\t\t],\n\t\t\"stateMutability\": \"nonpayable\",\n\t\t\"type\": \"constructor\"\n\t},\n\t{\n\t\t\"anonymous\": false,\n\t\t\"inputs\": [\n\t\t\t{\n\t\t\t\t\"indexed\": false,\n\t\t\t\t\"internalType\": \"address\",\n\t\t\t\t\"name\": \"winner\",\n\t\t\t\t\"type\": \"address\"\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"indexed\": false,\n\t\t\t\t\"internalType\": \"uint256\",\n\t\t\t\t\"name\": \"amount\",\n\t\t\t\t\"type\": \"uint256\"\n\t\t\t}\n\t\t],\n\t\t\"name\": \"AuctionEnded\",\n\t\t\"type\": \"event\"\n\t},\n\t{\n\t\t\"anonymous\": false,\n\t\t\"inputs\": [\n\t\t\t{\n\t\t\t\t\"indexed\": false,\n\t\t\t\t\"internalType\": \"address\",\n\t\t\t\t\"name\": \"bidder\",\n\t\t\t\t\"type\": \"address\"\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"indexed\": false,\n\t\t\t\t\"internalType\": \"uint256\",\n\t\t\t\t\"name\": \"amount\",\n\t\t\t\t\"type\": \"uint256\"\n\t\t\t}\n\t\t],\n\t\t\"name\": \"HighestBidIncreased\",\n\t\t\"type\": \"event\"\n\t},\n\t{\n\t\t\"inputs\": [],\n\t\t\"name\": \"auctionEnd\",\n\t\t\"outputs\": [],\n\t\t\"stateMutability\": \"nonpayable\",\n\t\t\"type\": \"function\"\n\t},\n\t{\n\t\t\"inputs\": [],\n\t\t\"name\": \"auctionStart\",\n\t\t\"outputs\": [\n\t\t\t{\n\t\t\t\t\"internalType\": \"uint256\",\n\t\t\t\t\"name\": \"\",\n\t\t\t\t\"type\": \"uint256\"\n\t\t\t}\n\t\t],\n\t\t\"stateMutability\": \"view\",\n\t\t\"type\": \"function\"\n\t},\n\t{\n\t\t\"inputs\": [],\n\t\t\"name\": \"beneficiary\",\n\t\t\"outputs\": [\n\t\t\t{\n\t\t\t\t\"internalType\": \"address\",\n\t\t\t\t\"name\": \"\",\n\t\t\t\t\"type\": \"address\"\n\t\t\t}\n\t\t],\n\t\t\"stateMutability\": \"view\",\n\t\t\"type\": \"function\"\n\t},\n\t{\n\t\t\"inputs\": [],\n\t\t\"name\": \"bid\",\n\t\t\"outputs\": [],\n\t\t\"stateMutability\": \"payable\",\n\t\t\"type\": \"function\"\n\t},\n\t{\n\t\t\"inputs\": [],\n\t\t\"name\": \"biddingTime\",\n\t\t\"outputs\": [\n\t\t\t{\n\t\t\t\t\"internalType\": \"uint256\",\n\t\t\t\t\"name\": \"\",\n\t\t\t\t\"type\": \"uint256\"\n\t\t\t}\n\t\t],\n\t\t\"stateMutability\": \"view\",\n\t\t\"type\": \"function\"\n\t},\n\t{\n\t\t\"inputs\": [],\n\t\t\"name\": \"highestBid\",\n\t\t\"outputs\": [\n\t\t\t{\n\t\t\t\t\"internalType\": \"uint256\",\n\t\t\t\t\"name\": \"\",\n\t\t\t\t\"type\": \"uint256\"\n\t\t\t}\n\t\t],\n\t\t\"stateMutability\": \"view\",\n\t\t\"type\": \"function\"\n\t},\n\t{\n\t\t\"inputs\": [],\n\t\t\"name\": \"highestBidder\",\n\t\t\"outputs\": [\n\t\t\t{\n\t\t\t\t\"internalType\": \"address\",\n\t\t\t\t\"name\": \"\",\n\t\t\t\t\"type\": \"address\"\n\t\t\t}\n\t\t],\n\t\t\"stateMutability\": \"view\",\n\t\t\"type\": \"function\"\n\t},\n\t{\n\t\t\"inputs\": [],\n\t\t\"name\": \"isBeatHigh\",\n\t\t\"outputs\": [\n\t\t\t{\n\t\t\t\t\"internalType\": \"bool\",\n\t\t\t\t\"name\": \"\",\n\t\t\t\t\"type\": \"bool\"\n\t\t\t}\n\t\t],\n\t\t\"stateMutability\": \"view\",\n\t\t\"type\": \"function\"\n\t},\n\t{\n\t\t\"inputs\": [],\n\t\t\"name\": \"withdraw\",\n\t\t\"outputs\": [\n\t\t\t{\n\t\t\t\t\"internalType\": \"bool\",\n\t\t\t\t\"name\": \"\",\n\t\t\t\t\"type\": \"bool\"\n\t\t\t}\n\t\t],\n\t\t\"stateMutability\": \"nonpayable\",\n\t\t\"type\": \"function\"\n\t},\n\t{\n\t\t\"inputs\": [],\n\t\t\"name\": \"withdrawAmount\",\n\t\t\"outputs\": [\n\t\t\t{\n\t\t\t\t\"internalType\": \"uint256\",\n\t\t\t\t\"name\": \"\",\n\t\t\t\t\"type\": \"uint256\"\n\t\t\t}\n\t\t],\n\t\t\"stateMutability\": \"view\",\n\t\t\"type\": \"function\"\n\t}\n]";
    final contract = DeployedContract(ContractAbi.fromJson(abiCode, 'ApuestaSimple'), contractAddr);

    final bitFunction = contract.function('bid');

    /*final result = await ethClient.call(
        contract: contract, function: bitFunction, params: []);*/

    final result = await ethClient.sendTransaction(
      chainId: 31337,
      credentials,
      Transaction.callContract(
          contract: contract,
          function: bitFunction,
          value: EtherAmount.fromInt(EtherUnit.ether, 20),
          parameters: []
      ),
    );

    // sign in and update the state (data or error)
    /*state = await AsyncValue.guard(() async {

      return await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: bitFunction,
          value: EtherAmount.fromInt(EtherUnit.ether, 10),
          parameters: []
        ),
      );

    });*/*/
    return "Error transactions";
  }
}

final bitProvider = StateNotifierProvider<
    BitState, AsyncValue<String>>((ref) {
  return BitState();
});