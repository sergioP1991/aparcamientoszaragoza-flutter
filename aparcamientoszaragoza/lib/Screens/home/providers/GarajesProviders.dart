
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart' as web3;

import '../../../Models/garaje.dart';
import '../../../Values/app_models.dart';

part 'GarajesProviders.g.dart';

final List<Garaje> garajesList = List<Garaje>.empty();

@Riverpod(keepAlive: true)
final garajeListProvider = StateProvider<List<Garaje>>((ref) {
  return garajesList;
});

@Riverpod(keepAlive: true)
Future<List<Garaje>> fetchGaraje(FetchGarajeRef ref) async {

  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('garaje').get();

  List<Garaje> listResult = snapshot.docs.map<Garaje>((doc) => Garaje.fromFirestore(doc)).toList();
  /*listResult.forEach((plaza) async {
    plaza.alquilada = await isAlquilada(AppModels.privateKeyEthAccount, plaza.idPlaza ?? 0);
  });*/

  listResult[0].alquilada = await isAlquilada(AppModels.privateKeyEthAccount, 0);
  listResult[1].alquilada = await isAlquilada(AppModels.privateKeyEthAccount, 1);

  ref.read(garajeListProvider.notifier).state = listResult;

  return listResult;
}

Future<bool> isAlquilada(String ethAccount, int idPlaza) async {

  //String privateKey = ethAccount;
  final EthereumAddress contractAddr = EthereumAddress.fromHex(AppModels.addresContract);

  var apiUrl = AppModels.apiUrlEth; //Replace with your API
  var httpClient = Client();
  var ethClient = web3.Web3Client(apiUrl, httpClient);
  final credentials = EthPrivateKey.fromHex(AppModels.privateKeyEthAccount);
  //final ownAddress = await credentials.extractAddress();
  final chainID = await ethClient.getChainId();
  String abiCode = AppModels.ethContractAbi;
  final contract = web3.DeployedContract(web3.ContractAbi.fromJson(abiCode, 'GestionAlquiler'), contractAddr);

  final isAlquiladoFunction = contract.function('isAlquilado');

  final resultCall = await ethClient.call(contract: contract, function: isAlquiladoFunction, params: [BigInt.from(idPlaza)]);
  /*final transactionHash = await ethClient.sendTransaction(
    chainId: 31337,
    credentials,
    web3.Transaction.callContract(
        contract: contract,
        function: isAlquiladoFunction,
        parameters: [BigInt.from(idPlaza)]
    ),
  );*/

  //final trasactionTotal = await ethClient.getTransactionByHash(transactionHash);
  //final trasactionReceipt = await ethClient.getTransactionReceipt(transactionHash);

  return resultCall[0];
}

class BitState extends StateNotifier<AsyncValue<String>> {
  BitState() : super(const AsyncData(""));

  Future<BigInt> getEth(String ethAccount) async {
    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {
      var apiUrl = "http://127.0.0.1:8545/"; //Replace with your API

      var httpClient = Client();
      var ethClient = web3.Web3Client(apiUrl, httpClient);

      var credentials = EthPrivateKey.fromHex(ethAccount);
      web3.EtherAmount balance = await ethClient.getBalance(
          credentials.address);

      return "" + balance.getInEther.toString();
    });
    return BigInt.zero;
  }
}

final bitProvider = StateNotifierProvider<
    BitState, AsyncValue<String>>((ref) {
  return BitState();
});