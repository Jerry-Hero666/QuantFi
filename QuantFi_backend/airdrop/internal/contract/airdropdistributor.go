// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package contract

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// ContractMetaData contains all meta data concerning the Contract contract.
var ContractMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"constructor\",\"inputs\":[{\"name\":\"token_\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"admin_\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"TOKEN\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"contractIERC20\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"claim\",\"inputs\":[{\"name\":\"roundId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"amount\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"proof\",\"type\":\"bytes32[]\",\"internalType\":\"bytes32[]\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"claimed\",\"inputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"bool\",\"internalType\":\"bool\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"closeRound\",\"inputs\":[{\"name\":\"roundId\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"owner\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"renounceOwnership\",\"inputs\":[],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"rounds\",\"inputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[{\"name\":\"merkleRoot\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"claimDeadline\",\"type\":\"uint64\",\"internalType\":\"uint64\"},{\"name\":\"active\",\"type\":\"bool\",\"internalType\":\"bool\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"startRound\",\"inputs\":[{\"name\":\"roundId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"merkleRoot\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"claimDeadline\",\"type\":\"uint64\",\"internalType\":\"uint64\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"transferOwnership\",\"inputs\":[{\"name\":\"newOwner\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"event\",\"name\":\"Claimed\",\"inputs\":[{\"name\":\"roundId\",\"type\":\"uint256\",\"indexed\":true,\"internalType\":\"uint256\"},{\"name\":\"account\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"leaf\",\"type\":\"bytes32\",\"indexed\":false,\"internalType\":\"bytes32\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"OwnershipTransferred\",\"inputs\":[{\"name\":\"previousOwner\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"newOwner\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"RoundClosed\",\"inputs\":[{\"name\":\"roundId\",\"type\":\"uint256\",\"indexed\":true,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"RoundStarted\",\"inputs\":[{\"name\":\"roundId\",\"type\":\"uint256\",\"indexed\":true,\"internalType\":\"uint256\"},{\"name\":\"merkleRoot\",\"type\":\"bytes32\",\"indexed\":true,\"internalType\":\"bytes32\"},{\"name\":\"claimDeadline\",\"type\":\"uint64\",\"indexed\":false,\"internalType\":\"uint64\"}],\"anonymous\":false},{\"type\":\"error\",\"name\":\"OwnableInvalidOwner\",\"inputs\":[{\"name\":\"owner\",\"type\":\"address\",\"internalType\":\"address\"}]},{\"type\":\"error\",\"name\":\"OwnableUnauthorizedAccount\",\"inputs\":[{\"name\":\"account\",\"type\":\"address\",\"internalType\":\"address\"}]},{\"type\":\"error\",\"name\":\"SafeERC20FailedOperation\",\"inputs\":[{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"}]}]",
	Bin: "0x60a060405234801561000f575f5ffd5b5060405161175d38038061175d8339818101604052810190610031919061027a565b805f73ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16036100a2575f6040517f1e4fbdf700000000000000000000000000000000000000000000000000000000815260040161009991906102c7565b60405180910390fd5b6100b18161015b60201b60201c565b505f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1603610120576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016101179061033a565b60405180910390fd5b8173ffffffffffffffffffffffffffffffffffffffff1660808173ffffffffffffffffffffffffffffffffffffffff16815250505050610358565b5f5f5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050815f5f6101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b5f5ffd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f61024982610220565b9050919050565b6102598161023f565b8114610263575f5ffd5b50565b5f8151905061027481610250565b92915050565b5f5f604083850312156102905761028f61021c565b5b5f61029d85828601610266565b92505060206102ae85828601610266565b9150509250929050565b6102c18161023f565b82525050565b5f6020820190506102da5f8301846102b8565b92915050565b5f82825260208201905092915050565b7f746f6b656e2072657175697265640000000000000000000000000000000000005f82015250565b5f610324600e836102e0565b915061032f826102f0565b602082019050919050565b5f6020820190508181035f83015261035181610318565b9050919050565b6080516113e66103775f395f818161039601526107e101526113e65ff3fe608060405234801561000f575f5ffd5b5060043610610091575f3560e01c806388e01a981161006457806388e01a98146101095780638c65c81f146101255780638da5cb5b14610157578063ae0b51df14610175578063f2fde38b1461019157610091565b8063120aa877146100955780632e6397bb146100c5578063715018a6146100e157806382bfefc8146100eb575b5f5ffd5b6100af60048036038101906100aa9190610c34565b6101ad565b6040516100bc9190610c8c565b60405180910390f35b6100df60048036038101906100da9190610d15565b6101d7565b005b6100e9610381565b005b6100f3610394565b6040516101009190610dc0565b60405180910390f35b610123600480360381019061011e9190610dd9565b6103b8565b005b61013f600480360381019061013a9190610dd9565b610472565b60405161014e93929190610e22565b60405180910390f35b61015f6104b8565b60405161016c9190610e66565b60405180910390f35b61018f600480360381019061018a9190610ee0565b6104df565b005b6101ab60048036038101906101a69190610f51565b61087e565b005b6002602052815f5260405f20602052805f5260405f205f915091509054906101000a900460ff1681565b6101df610902565b5f8311610221576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161021890610fd6565b60405180910390fd5b5f5f1b8203610265576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161025c9061103e565b60405180910390fd5b428167ffffffffffffffff16116102b1576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016102a8906110a6565b60405180910390fd5b60405180606001604052808381526020018267ffffffffffffffff1681526020016001151581525060015f8581526020019081526020015f205f820151815f01556020820151816001015f6101000a81548167ffffffffffffffff021916908367ffffffffffffffff16021790555060408201518160010160086101000a81548160ff02191690831515021790555090505081837fbbd96cadb2f5e4176b1453ebc695920f05c998d9e48d2984c5a9b3cbcac288c88360405161037491906110c4565b60405180910390a3505050565b610389610902565b6103925f610989565b565b7f000000000000000000000000000000000000000000000000000000000000000081565b6103c0610902565b5f60015f8381526020019081526020015f2090508060010160089054906101000a900460ff16610425576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161041c90611127565b60405180910390fd5b5f8160010160086101000a81548160ff021916908315150217905550817fe9f7d7fd0b133404f0ccff737d6f3594748e04bc5507adfaed35835ef989371160405160405180910390a25050565b6001602052805f5260405f205f91509050805f015490806001015f9054906101000a900467ffffffffffffffff16908060010160089054906101000a900460ff16905083565b5f5f5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b5f60015f8681526020019081526020015f206040518060600160405290815f8201548152602001600182015f9054906101000a900467ffffffffffffffff1667ffffffffffffffff1667ffffffffffffffff1681526020016001820160089054906101000a900460ff16151515158152505090508060400151610597576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161058e9061118f565b60405180910390fd5b806020015167ffffffffffffffff164211156105e8576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016105df906111f7565b60405180910390fd5b60025f8681526020019081526020015f205f3373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f9054906101000a900460ff1615610681576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016106789061125f565b60405180910390fd5b5f84116106c3576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016106ba906112c7565b60405180910390fd5b5f6040518681523360601b6020820152603481018681526054822092506060820160405250506107378484808060200260200160405190810160405280939291908181526020018383602002808284375f81840152601f19601f82011690508083019250505050505050835f015183610a4a565b610776576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161076d9061132f565b60405180910390fd5b600160025f8881526020019081526020015f205f3373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f6101000a81548160ff02191690831515021790555061082533867f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff16610a609092919063ffffffff16565b3373ffffffffffffffffffffffffffffffffffffffff16867f04672052dcb6b5b19a9cc2ec1b8f447f1f5e47b5e24cfa5e4ffb640d63ca2be7878460405161086e92919061135c565b60405180910390a3505050505050565b610886610902565b5f73ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16036108f6575f6040517f1e4fbdf70000000000000000000000000000000000000000000000000000000081526004016108ed9190610e66565b60405180910390fd5b6108ff81610989565b50565b61090a610ab3565b73ffffffffffffffffffffffffffffffffffffffff166109286104b8565b73ffffffffffffffffffffffffffffffffffffffff16146109875761094b610ab3565b6040517f118cdaa700000000000000000000000000000000000000000000000000000000815260040161097e9190610e66565b60405180910390fd5b565b5f5f5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050815f5f6101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b5f82610a568584610aba565b1490509392505050565b610a6d8383836001610b29565b610aae57826040517f5274afe7000000000000000000000000000000000000000000000000000000008152600401610aa59190610e66565b60405180910390fd5b505050565b5f33905090565b5f5f8290505f5f90505b8451811015610b1e575f858281518110610ae157610ae0611383565b5b60200260200101519050808311610b0357610afc8382610b8b565b9250610b10565b610b0d8184610b8b565b92505b508080600101915050610ac4565b508091505092915050565b5f5f63a9059cbb60e01b9050604051815f525f1960601c86166004528460245260205f60445f5f8b5af1925060015f51148316610b7d578383151615610b71573d5f823e3d81fd5b5f873b113d1516831692505b806040525050949350505050565b5f825f528160205260405f20905092915050565b5f5ffd5b5f5ffd5b5f819050919050565b610bb981610ba7565b8114610bc3575f5ffd5b50565b5f81359050610bd481610bb0565b92915050565b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f610c0382610bda565b9050919050565b610c1381610bf9565b8114610c1d575f5ffd5b50565b5f81359050610c2e81610c0a565b92915050565b5f5f60408385031215610c4a57610c49610b9f565b5b5f610c5785828601610bc6565b9250506020610c6885828601610c20565b9150509250929050565b5f8115159050919050565b610c8681610c72565b82525050565b5f602082019050610c9f5f830184610c7d565b92915050565b5f819050919050565b610cb781610ca5565b8114610cc1575f5ffd5b50565b5f81359050610cd281610cae565b92915050565b5f67ffffffffffffffff82169050919050565b610cf481610cd8565b8114610cfe575f5ffd5b50565b5f81359050610d0f81610ceb565b92915050565b5f5f5f60608486031215610d2c57610d2b610b9f565b5b5f610d3986828701610bc6565b9350506020610d4a86828701610cc4565b9250506040610d5b86828701610d01565b9150509250925092565b5f819050919050565b5f610d88610d83610d7e84610bda565b610d65565b610bda565b9050919050565b5f610d9982610d6e565b9050919050565b5f610daa82610d8f565b9050919050565b610dba81610da0565b82525050565b5f602082019050610dd35f830184610db1565b92915050565b5f60208284031215610dee57610ded610b9f565b5b5f610dfb84828501610bc6565b91505092915050565b610e0d81610ca5565b82525050565b610e1c81610cd8565b82525050565b5f606082019050610e355f830186610e04565b610e426020830185610e13565b610e4f6040830184610c7d565b949350505050565b610e6081610bf9565b82525050565b5f602082019050610e795f830184610e57565b92915050565b5f5ffd5b5f5ffd5b5f5ffd5b5f5f83601f840112610ea057610e9f610e7f565b5b8235905067ffffffffffffffff811115610ebd57610ebc610e83565b5b602083019150836020820283011115610ed957610ed8610e87565b5b9250929050565b5f5f5f5f60608587031215610ef857610ef7610b9f565b5b5f610f0587828801610bc6565b9450506020610f1687828801610bc6565b935050604085013567ffffffffffffffff811115610f3757610f36610ba3565b5b610f4387828801610e8b565b925092505092959194509250565b5f60208284031215610f6657610f65610b9f565b5b5f610f7384828501610c20565b91505092915050565b5f82825260208201905092915050565b7f726f756e643d30000000000000000000000000000000000000000000000000005f82015250565b5f610fc0600783610f7c565b9150610fcb82610f8c565b602082019050919050565b5f6020820190508181035f830152610fed81610fb4565b9050919050565b7f726f6f74207265717569726564000000000000000000000000000000000000005f82015250565b5f611028600d83610f7c565b915061103382610ff4565b602082019050919050565b5f6020820190508181035f8301526110558161101c565b9050919050565b7f646561646c696e6520696e76616c6964000000000000000000000000000000005f82015250565b5f611090601083610f7c565b915061109b8261105c565b602082019050919050565b5f6020820190508181035f8301526110bd81611084565b9050919050565b5f6020820190506110d75f830184610e13565b92915050565b7f726f756e64206e6f7420616374697665000000000000000000000000000000005f82015250565b5f611111601083610f7c565b915061111c826110dd565b602082019050919050565b5f6020820190508181035f83015261113e81611105565b9050919050565b7f696e6163746976650000000000000000000000000000000000000000000000005f82015250565b5f611179600883610f7c565b915061118482611145565b602082019050919050565b5f6020820190508181035f8301526111a68161116d565b9050919050565b7f65787069726564000000000000000000000000000000000000000000000000005f82015250565b5f6111e1600783610f7c565b91506111ec826111ad565b602082019050919050565b5f6020820190508181035f83015261120e816111d5565b9050919050565b7f636c61696d6564000000000000000000000000000000000000000000000000005f82015250565b5f611249600783610f7c565b915061125482611215565b602082019050919050565b5f6020820190508181035f8301526112768161123d565b9050919050565b7f616d6f756e743d300000000000000000000000000000000000000000000000005f82015250565b5f6112b1600883610f7c565b91506112bc8261127d565b602082019050919050565b5f6020820190508181035f8301526112de816112a5565b9050919050565b7f696e76616c69642070726f6f66000000000000000000000000000000000000005f82015250565b5f611319600d83610f7c565b9150611324826112e5565b602082019050919050565b5f6020820190508181035f8301526113468161130d565b9050919050565b61135681610ba7565b82525050565b5f60408201905061136f5f83018561134d565b61137c6020830184610e04565b9392505050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52603260045260245ffdfea2646970667358221220e2844ad50586279e3eddf1566588ee5647a3114b0ac52d477376cc82cb35128664736f6c634300081e0033",
}

// ContractABI is the input ABI used to generate the binding from.
// Deprecated: Use ContractMetaData.ABI instead.
var ContractABI = ContractMetaData.ABI

// ContractBin is the compiled bytecode used for deploying new contracts.
// Deprecated: Use ContractMetaData.Bin instead.
var ContractBin = ContractMetaData.Bin

// DeployContract deploys a new Ethereum contract, binding an instance of Contract to it.
func DeployContract(auth *bind.TransactOpts, backend bind.ContractBackend, token_ common.Address, admin_ common.Address) (common.Address, *types.Transaction, *Contract, error) {
	parsed, err := ContractMetaData.GetAbi()
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	if parsed == nil {
		return common.Address{}, nil, nil, errors.New("GetABI returned nil")
	}

	address, tx, contract, err := bind.DeployContract(auth, *parsed, common.FromHex(ContractBin), backend, token_, admin_)
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	return address, tx, &Contract{ContractCaller: ContractCaller{contract: contract}, ContractTransactor: ContractTransactor{contract: contract}, ContractFilterer: ContractFilterer{contract: contract}}, nil
}

// Contract is an auto generated Go binding around an Ethereum contract.
type Contract struct {
	ContractCaller     // Read-only binding to the contract
	ContractTransactor // Write-only binding to the contract
	ContractFilterer   // Log filterer for contract events
}

// ContractCaller is an auto generated read-only Go binding around an Ethereum contract.
type ContractCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// ContractTransactor is an auto generated write-only Go binding around an Ethereum contract.
type ContractTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// ContractFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type ContractFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// ContractSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type ContractSession struct {
	Contract     *Contract         // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// ContractCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type ContractCallerSession struct {
	Contract *ContractCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts   // Call options to use throughout this session
}

// ContractTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type ContractTransactorSession struct {
	Contract     *ContractTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts   // Transaction auth options to use throughout this session
}

// ContractRaw is an auto generated low-level Go binding around an Ethereum contract.
type ContractRaw struct {
	Contract *Contract // Generic contract binding to access the raw methods on
}

// ContractCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type ContractCallerRaw struct {
	Contract *ContractCaller // Generic read-only contract binding to access the raw methods on
}

// ContractTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type ContractTransactorRaw struct {
	Contract *ContractTransactor // Generic write-only contract binding to access the raw methods on
}

// NewContract creates a new instance of Contract, bound to a specific deployed contract.
func NewContract(address common.Address, backend bind.ContractBackend) (*Contract, error) {
	contract, err := bindContract(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &Contract{ContractCaller: ContractCaller{contract: contract}, ContractTransactor: ContractTransactor{contract: contract}, ContractFilterer: ContractFilterer{contract: contract}}, nil
}

// NewContractCaller creates a new read-only instance of Contract, bound to a specific deployed contract.
func NewContractCaller(address common.Address, caller bind.ContractCaller) (*ContractCaller, error) {
	contract, err := bindContract(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &ContractCaller{contract: contract}, nil
}

// NewContractTransactor creates a new write-only instance of Contract, bound to a specific deployed contract.
func NewContractTransactor(address common.Address, transactor bind.ContractTransactor) (*ContractTransactor, error) {
	contract, err := bindContract(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &ContractTransactor{contract: contract}, nil
}

// NewContractFilterer creates a new log filterer instance of Contract, bound to a specific deployed contract.
func NewContractFilterer(address common.Address, filterer bind.ContractFilterer) (*ContractFilterer, error) {
	contract, err := bindContract(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &ContractFilterer{contract: contract}, nil
}

// bindContract binds a generic wrapper to an already deployed contract.
func bindContract(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := ContractMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Contract *ContractRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Contract.Contract.ContractCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Contract *ContractRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Contract.Contract.ContractTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Contract *ContractRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Contract.Contract.ContractTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Contract *ContractCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Contract.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Contract *ContractTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Contract.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Contract *ContractTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Contract.Contract.contract.Transact(opts, method, params...)
}

// TOKEN is a free data retrieval call binding the contract method 0x82bfefc8.
//
// Solidity: function TOKEN() view returns(address)
func (_Contract *ContractCaller) TOKEN(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _Contract.contract.Call(opts, &out, "TOKEN")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// TOKEN is a free data retrieval call binding the contract method 0x82bfefc8.
//
// Solidity: function TOKEN() view returns(address)
func (_Contract *ContractSession) TOKEN() (common.Address, error) {
	return _Contract.Contract.TOKEN(&_Contract.CallOpts)
}

// TOKEN is a free data retrieval call binding the contract method 0x82bfefc8.
//
// Solidity: function TOKEN() view returns(address)
func (_Contract *ContractCallerSession) TOKEN() (common.Address, error) {
	return _Contract.Contract.TOKEN(&_Contract.CallOpts)
}

// Claimed is a free data retrieval call binding the contract method 0x120aa877.
//
// Solidity: function claimed(uint256 , address ) view returns(bool)
func (_Contract *ContractCaller) Claimed(opts *bind.CallOpts, arg0 *big.Int, arg1 common.Address) (bool, error) {
	var out []interface{}
	err := _Contract.contract.Call(opts, &out, "claimed", arg0, arg1)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// Claimed is a free data retrieval call binding the contract method 0x120aa877.
//
// Solidity: function claimed(uint256 , address ) view returns(bool)
func (_Contract *ContractSession) Claimed(arg0 *big.Int, arg1 common.Address) (bool, error) {
	return _Contract.Contract.Claimed(&_Contract.CallOpts, arg0, arg1)
}

// Claimed is a free data retrieval call binding the contract method 0x120aa877.
//
// Solidity: function claimed(uint256 , address ) view returns(bool)
func (_Contract *ContractCallerSession) Claimed(arg0 *big.Int, arg1 common.Address) (bool, error) {
	return _Contract.Contract.Claimed(&_Contract.CallOpts, arg0, arg1)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Contract *ContractCaller) Owner(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _Contract.contract.Call(opts, &out, "owner")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Contract *ContractSession) Owner() (common.Address, error) {
	return _Contract.Contract.Owner(&_Contract.CallOpts)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Contract *ContractCallerSession) Owner() (common.Address, error) {
	return _Contract.Contract.Owner(&_Contract.CallOpts)
}

// Rounds is a free data retrieval call binding the contract method 0x8c65c81f.
//
// Solidity: function rounds(uint256 ) view returns(bytes32 merkleRoot, uint64 claimDeadline, bool active)
func (_Contract *ContractCaller) Rounds(opts *bind.CallOpts, arg0 *big.Int) (struct {
	MerkleRoot    [32]byte
	ClaimDeadline uint64
	Active        bool
}, error) {
	var out []interface{}
	err := _Contract.contract.Call(opts, &out, "rounds", arg0)

	outstruct := new(struct {
		MerkleRoot    [32]byte
		ClaimDeadline uint64
		Active        bool
	})
	if err != nil {
		return *outstruct, err
	}

	outstruct.MerkleRoot = *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)
	outstruct.ClaimDeadline = *abi.ConvertType(out[1], new(uint64)).(*uint64)
	outstruct.Active = *abi.ConvertType(out[2], new(bool)).(*bool)

	return *outstruct, err

}

// Rounds is a free data retrieval call binding the contract method 0x8c65c81f.
//
// Solidity: function rounds(uint256 ) view returns(bytes32 merkleRoot, uint64 claimDeadline, bool active)
func (_Contract *ContractSession) Rounds(arg0 *big.Int) (struct {
	MerkleRoot    [32]byte
	ClaimDeadline uint64
	Active        bool
}, error) {
	return _Contract.Contract.Rounds(&_Contract.CallOpts, arg0)
}

// Rounds is a free data retrieval call binding the contract method 0x8c65c81f.
//
// Solidity: function rounds(uint256 ) view returns(bytes32 merkleRoot, uint64 claimDeadline, bool active)
func (_Contract *ContractCallerSession) Rounds(arg0 *big.Int) (struct {
	MerkleRoot    [32]byte
	ClaimDeadline uint64
	Active        bool
}, error) {
	return _Contract.Contract.Rounds(&_Contract.CallOpts, arg0)
}

// Claim is a paid mutator transaction binding the contract method 0xae0b51df.
//
// Solidity: function claim(uint256 roundId, uint256 amount, bytes32[] proof) returns()
func (_Contract *ContractTransactor) Claim(opts *bind.TransactOpts, roundId *big.Int, amount *big.Int, proof [][32]byte) (*types.Transaction, error) {
	return _Contract.contract.Transact(opts, "claim", roundId, amount, proof)
}

// Claim is a paid mutator transaction binding the contract method 0xae0b51df.
//
// Solidity: function claim(uint256 roundId, uint256 amount, bytes32[] proof) returns()
func (_Contract *ContractSession) Claim(roundId *big.Int, amount *big.Int, proof [][32]byte) (*types.Transaction, error) {
	return _Contract.Contract.Claim(&_Contract.TransactOpts, roundId, amount, proof)
}

// Claim is a paid mutator transaction binding the contract method 0xae0b51df.
//
// Solidity: function claim(uint256 roundId, uint256 amount, bytes32[] proof) returns()
func (_Contract *ContractTransactorSession) Claim(roundId *big.Int, amount *big.Int, proof [][32]byte) (*types.Transaction, error) {
	return _Contract.Contract.Claim(&_Contract.TransactOpts, roundId, amount, proof)
}

// CloseRound is a paid mutator transaction binding the contract method 0x88e01a98.
//
// Solidity: function closeRound(uint256 roundId) returns()
func (_Contract *ContractTransactor) CloseRound(opts *bind.TransactOpts, roundId *big.Int) (*types.Transaction, error) {
	return _Contract.contract.Transact(opts, "closeRound", roundId)
}

// CloseRound is a paid mutator transaction binding the contract method 0x88e01a98.
//
// Solidity: function closeRound(uint256 roundId) returns()
func (_Contract *ContractSession) CloseRound(roundId *big.Int) (*types.Transaction, error) {
	return _Contract.Contract.CloseRound(&_Contract.TransactOpts, roundId)
}

// CloseRound is a paid mutator transaction binding the contract method 0x88e01a98.
//
// Solidity: function closeRound(uint256 roundId) returns()
func (_Contract *ContractTransactorSession) CloseRound(roundId *big.Int) (*types.Transaction, error) {
	return _Contract.Contract.CloseRound(&_Contract.TransactOpts, roundId)
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x715018a6.
//
// Solidity: function renounceOwnership() returns()
func (_Contract *ContractTransactor) RenounceOwnership(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Contract.contract.Transact(opts, "renounceOwnership")
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x715018a6.
//
// Solidity: function renounceOwnership() returns()
func (_Contract *ContractSession) RenounceOwnership() (*types.Transaction, error) {
	return _Contract.Contract.RenounceOwnership(&_Contract.TransactOpts)
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x715018a6.
//
// Solidity: function renounceOwnership() returns()
func (_Contract *ContractTransactorSession) RenounceOwnership() (*types.Transaction, error) {
	return _Contract.Contract.RenounceOwnership(&_Contract.TransactOpts)
}

// StartRound is a paid mutator transaction binding the contract method 0x2e6397bb.
//
// Solidity: function startRound(uint256 roundId, bytes32 merkleRoot, uint64 claimDeadline) returns()
func (_Contract *ContractTransactor) StartRound(opts *bind.TransactOpts, roundId *big.Int, merkleRoot [32]byte, claimDeadline uint64) (*types.Transaction, error) {
	return _Contract.contract.Transact(opts, "startRound", roundId, merkleRoot, claimDeadline)
}

// StartRound is a paid mutator transaction binding the contract method 0x2e6397bb.
//
// Solidity: function startRound(uint256 roundId, bytes32 merkleRoot, uint64 claimDeadline) returns()
func (_Contract *ContractSession) StartRound(roundId *big.Int, merkleRoot [32]byte, claimDeadline uint64) (*types.Transaction, error) {
	return _Contract.Contract.StartRound(&_Contract.TransactOpts, roundId, merkleRoot, claimDeadline)
}

// StartRound is a paid mutator transaction binding the contract method 0x2e6397bb.
//
// Solidity: function startRound(uint256 roundId, bytes32 merkleRoot, uint64 claimDeadline) returns()
func (_Contract *ContractTransactorSession) StartRound(roundId *big.Int, merkleRoot [32]byte, claimDeadline uint64) (*types.Transaction, error) {
	return _Contract.Contract.StartRound(&_Contract.TransactOpts, roundId, merkleRoot, claimDeadline)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0xf2fde38b.
//
// Solidity: function transferOwnership(address newOwner) returns()
func (_Contract *ContractTransactor) TransferOwnership(opts *bind.TransactOpts, newOwner common.Address) (*types.Transaction, error) {
	return _Contract.contract.Transact(opts, "transferOwnership", newOwner)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0xf2fde38b.
//
// Solidity: function transferOwnership(address newOwner) returns()
func (_Contract *ContractSession) TransferOwnership(newOwner common.Address) (*types.Transaction, error) {
	return _Contract.Contract.TransferOwnership(&_Contract.TransactOpts, newOwner)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0xf2fde38b.
//
// Solidity: function transferOwnership(address newOwner) returns()
func (_Contract *ContractTransactorSession) TransferOwnership(newOwner common.Address) (*types.Transaction, error) {
	return _Contract.Contract.TransferOwnership(&_Contract.TransactOpts, newOwner)
}

// ContractClaimedIterator is returned from FilterClaimed and is used to iterate over the raw logs and unpacked data for Claimed events raised by the Contract contract.
type ContractClaimedIterator struct {
	Event *ContractClaimed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *ContractClaimedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(ContractClaimed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(ContractClaimed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *ContractClaimedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *ContractClaimedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// ContractClaimed represents a Claimed event raised by the Contract contract.
type ContractClaimed struct {
	RoundId *big.Int
	Account common.Address
	Amount  *big.Int
	Leaf    [32]byte
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterClaimed is a free log retrieval operation binding the contract event 0x04672052dcb6b5b19a9cc2ec1b8f447f1f5e47b5e24cfa5e4ffb640d63ca2be7.
//
// Solidity: event Claimed(uint256 indexed roundId, address indexed account, uint256 amount, bytes32 leaf)
func (_Contract *ContractFilterer) FilterClaimed(opts *bind.FilterOpts, roundId []*big.Int, account []common.Address) (*ContractClaimedIterator, error) {

	var roundIdRule []interface{}
	for _, roundIdItem := range roundId {
		roundIdRule = append(roundIdRule, roundIdItem)
	}
	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}

	logs, sub, err := _Contract.contract.FilterLogs(opts, "Claimed", roundIdRule, accountRule)
	if err != nil {
		return nil, err
	}
	return &ContractClaimedIterator{contract: _Contract.contract, event: "Claimed", logs: logs, sub: sub}, nil
}

// WatchClaimed is a free log subscription operation binding the contract event 0x04672052dcb6b5b19a9cc2ec1b8f447f1f5e47b5e24cfa5e4ffb640d63ca2be7.
//
// Solidity: event Claimed(uint256 indexed roundId, address indexed account, uint256 amount, bytes32 leaf)
func (_Contract *ContractFilterer) WatchClaimed(opts *bind.WatchOpts, sink chan<- *ContractClaimed, roundId []*big.Int, account []common.Address) (event.Subscription, error) {

	var roundIdRule []interface{}
	for _, roundIdItem := range roundId {
		roundIdRule = append(roundIdRule, roundIdItem)
	}
	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}

	logs, sub, err := _Contract.contract.WatchLogs(opts, "Claimed", roundIdRule, accountRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(ContractClaimed)
				if err := _Contract.contract.UnpackLog(event, "Claimed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseClaimed is a log parse operation binding the contract event 0x04672052dcb6b5b19a9cc2ec1b8f447f1f5e47b5e24cfa5e4ffb640d63ca2be7.
//
// Solidity: event Claimed(uint256 indexed roundId, address indexed account, uint256 amount, bytes32 leaf)
func (_Contract *ContractFilterer) ParseClaimed(log types.Log) (*ContractClaimed, error) {
	event := new(ContractClaimed)
	if err := _Contract.contract.UnpackLog(event, "Claimed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// ContractOwnershipTransferredIterator is returned from FilterOwnershipTransferred and is used to iterate over the raw logs and unpacked data for OwnershipTransferred events raised by the Contract contract.
type ContractOwnershipTransferredIterator struct {
	Event *ContractOwnershipTransferred // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *ContractOwnershipTransferredIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(ContractOwnershipTransferred)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(ContractOwnershipTransferred)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *ContractOwnershipTransferredIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *ContractOwnershipTransferredIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// ContractOwnershipTransferred represents a OwnershipTransferred event raised by the Contract contract.
type ContractOwnershipTransferred struct {
	PreviousOwner common.Address
	NewOwner      common.Address
	Raw           types.Log // Blockchain specific contextual infos
}

// FilterOwnershipTransferred is a free log retrieval operation binding the contract event 0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0.
//
// Solidity: event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
func (_Contract *ContractFilterer) FilterOwnershipTransferred(opts *bind.FilterOpts, previousOwner []common.Address, newOwner []common.Address) (*ContractOwnershipTransferredIterator, error) {

	var previousOwnerRule []interface{}
	for _, previousOwnerItem := range previousOwner {
		previousOwnerRule = append(previousOwnerRule, previousOwnerItem)
	}
	var newOwnerRule []interface{}
	for _, newOwnerItem := range newOwner {
		newOwnerRule = append(newOwnerRule, newOwnerItem)
	}

	logs, sub, err := _Contract.contract.FilterLogs(opts, "OwnershipTransferred", previousOwnerRule, newOwnerRule)
	if err != nil {
		return nil, err
	}
	return &ContractOwnershipTransferredIterator{contract: _Contract.contract, event: "OwnershipTransferred", logs: logs, sub: sub}, nil
}

// WatchOwnershipTransferred is a free log subscription operation binding the contract event 0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0.
//
// Solidity: event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
func (_Contract *ContractFilterer) WatchOwnershipTransferred(opts *bind.WatchOpts, sink chan<- *ContractOwnershipTransferred, previousOwner []common.Address, newOwner []common.Address) (event.Subscription, error) {

	var previousOwnerRule []interface{}
	for _, previousOwnerItem := range previousOwner {
		previousOwnerRule = append(previousOwnerRule, previousOwnerItem)
	}
	var newOwnerRule []interface{}
	for _, newOwnerItem := range newOwner {
		newOwnerRule = append(newOwnerRule, newOwnerItem)
	}

	logs, sub, err := _Contract.contract.WatchLogs(opts, "OwnershipTransferred", previousOwnerRule, newOwnerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(ContractOwnershipTransferred)
				if err := _Contract.contract.UnpackLog(event, "OwnershipTransferred", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseOwnershipTransferred is a log parse operation binding the contract event 0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0.
//
// Solidity: event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
func (_Contract *ContractFilterer) ParseOwnershipTransferred(log types.Log) (*ContractOwnershipTransferred, error) {
	event := new(ContractOwnershipTransferred)
	if err := _Contract.contract.UnpackLog(event, "OwnershipTransferred", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// ContractRoundClosedIterator is returned from FilterRoundClosed and is used to iterate over the raw logs and unpacked data for RoundClosed events raised by the Contract contract.
type ContractRoundClosedIterator struct {
	Event *ContractRoundClosed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *ContractRoundClosedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(ContractRoundClosed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(ContractRoundClosed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *ContractRoundClosedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *ContractRoundClosedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// ContractRoundClosed represents a RoundClosed event raised by the Contract contract.
type ContractRoundClosed struct {
	RoundId *big.Int
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterRoundClosed is a free log retrieval operation binding the contract event 0xe9f7d7fd0b133404f0ccff737d6f3594748e04bc5507adfaed35835ef9893711.
//
// Solidity: event RoundClosed(uint256 indexed roundId)
func (_Contract *ContractFilterer) FilterRoundClosed(opts *bind.FilterOpts, roundId []*big.Int) (*ContractRoundClosedIterator, error) {

	var roundIdRule []interface{}
	for _, roundIdItem := range roundId {
		roundIdRule = append(roundIdRule, roundIdItem)
	}

	logs, sub, err := _Contract.contract.FilterLogs(opts, "RoundClosed", roundIdRule)
	if err != nil {
		return nil, err
	}
	return &ContractRoundClosedIterator{contract: _Contract.contract, event: "RoundClosed", logs: logs, sub: sub}, nil
}

// WatchRoundClosed is a free log subscription operation binding the contract event 0xe9f7d7fd0b133404f0ccff737d6f3594748e04bc5507adfaed35835ef9893711.
//
// Solidity: event RoundClosed(uint256 indexed roundId)
func (_Contract *ContractFilterer) WatchRoundClosed(opts *bind.WatchOpts, sink chan<- *ContractRoundClosed, roundId []*big.Int) (event.Subscription, error) {

	var roundIdRule []interface{}
	for _, roundIdItem := range roundId {
		roundIdRule = append(roundIdRule, roundIdItem)
	}

	logs, sub, err := _Contract.contract.WatchLogs(opts, "RoundClosed", roundIdRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(ContractRoundClosed)
				if err := _Contract.contract.UnpackLog(event, "RoundClosed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseRoundClosed is a log parse operation binding the contract event 0xe9f7d7fd0b133404f0ccff737d6f3594748e04bc5507adfaed35835ef9893711.
//
// Solidity: event RoundClosed(uint256 indexed roundId)
func (_Contract *ContractFilterer) ParseRoundClosed(log types.Log) (*ContractRoundClosed, error) {
	event := new(ContractRoundClosed)
	if err := _Contract.contract.UnpackLog(event, "RoundClosed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// ContractRoundStartedIterator is returned from FilterRoundStarted and is used to iterate over the raw logs and unpacked data for RoundStarted events raised by the Contract contract.
type ContractRoundStartedIterator struct {
	Event *ContractRoundStarted // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *ContractRoundStartedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(ContractRoundStarted)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(ContractRoundStarted)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *ContractRoundStartedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *ContractRoundStartedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// ContractRoundStarted represents a RoundStarted event raised by the Contract contract.
type ContractRoundStarted struct {
	RoundId       *big.Int
	MerkleRoot    [32]byte
	ClaimDeadline uint64
	Raw           types.Log // Blockchain specific contextual infos
}

// FilterRoundStarted is a free log retrieval operation binding the contract event 0xbbd96cadb2f5e4176b1453ebc695920f05c998d9e48d2984c5a9b3cbcac288c8.
//
// Solidity: event RoundStarted(uint256 indexed roundId, bytes32 indexed merkleRoot, uint64 claimDeadline)
func (_Contract *ContractFilterer) FilterRoundStarted(opts *bind.FilterOpts, roundId []*big.Int, merkleRoot [][32]byte) (*ContractRoundStartedIterator, error) {

	var roundIdRule []interface{}
	for _, roundIdItem := range roundId {
		roundIdRule = append(roundIdRule, roundIdItem)
	}
	var merkleRootRule []interface{}
	for _, merkleRootItem := range merkleRoot {
		merkleRootRule = append(merkleRootRule, merkleRootItem)
	}

	logs, sub, err := _Contract.contract.FilterLogs(opts, "RoundStarted", roundIdRule, merkleRootRule)
	if err != nil {
		return nil, err
	}
	return &ContractRoundStartedIterator{contract: _Contract.contract, event: "RoundStarted", logs: logs, sub: sub}, nil
}

// WatchRoundStarted is a free log subscription operation binding the contract event 0xbbd96cadb2f5e4176b1453ebc695920f05c998d9e48d2984c5a9b3cbcac288c8.
//
// Solidity: event RoundStarted(uint256 indexed roundId, bytes32 indexed merkleRoot, uint64 claimDeadline)
func (_Contract *ContractFilterer) WatchRoundStarted(opts *bind.WatchOpts, sink chan<- *ContractRoundStarted, roundId []*big.Int, merkleRoot [][32]byte) (event.Subscription, error) {

	var roundIdRule []interface{}
	for _, roundIdItem := range roundId {
		roundIdRule = append(roundIdRule, roundIdItem)
	}
	var merkleRootRule []interface{}
	for _, merkleRootItem := range merkleRoot {
		merkleRootRule = append(merkleRootRule, merkleRootItem)
	}

	logs, sub, err := _Contract.contract.WatchLogs(opts, "RoundStarted", roundIdRule, merkleRootRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(ContractRoundStarted)
				if err := _Contract.contract.UnpackLog(event, "RoundStarted", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseRoundStarted is a log parse operation binding the contract event 0xbbd96cadb2f5e4176b1453ebc695920f05c998d9e48d2984c5a9b3cbcac288c8.
//
// Solidity: event RoundStarted(uint256 indexed roundId, bytes32 indexed merkleRoot, uint64 claimDeadline)
func (_Contract *ContractFilterer) ParseRoundStarted(log types.Log) (*ContractRoundStarted, error) {
	event := new(ContractRoundStarted)
	if err := _Contract.contract.UnpackLog(event, "RoundStarted", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
