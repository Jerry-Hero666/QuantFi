import { useReadContract, useWriteContract, useWaitForTransactionReceipt, useAccount } from 'wagmi';
import { contracts, ERC20_ABI, tokenAddresses, type TokenSymbol } from '../contracts';
import { parseUnits, formatUnits } from 'viem';

// Hook for reading token balance
export function useTokenBalance(tokenSymbol: TokenSymbol) {
  const { address } = useAccount();
  const tokenAddress = tokenAddresses[tokenSymbol];

  const { data: balance, isLoading, refetch } = useReadContract({
    address: tokenAddress,
    abi: ERC20_ABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });

  return {
    balance: balance ? formatUnits(balance as bigint, 18) : '0',
    rawBalance: balance as bigint | undefined,
    isLoading,
    refetch,
  };
}

// Hook for token approval
export function useTokenApprove(tokenSymbol: TokenSymbol, spenderAddress: `0x${string}`) {
  const tokenAddress = tokenAddresses[tokenSymbol];
  const { writeContract, data: hash, isPending } = useWriteContract();

  const approve = async (amount: string, decimals = 18) => {
    const amountInWei = parseUnits(amount, decimals);
    return writeContract({
      address: tokenAddress,
      abi: ERC20_ABI,
      functionName: 'approve',
      args: [spenderAddress, amountInWei],
    });
  };

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    approve,
    isPending,
    isConfirming,
    isSuccess,
    hash,
  };
}

// Hook for checking token allowance
export function useTokenAllowance(tokenSymbol: TokenSymbol, spenderAddress: `0x${string}`) {
  const { address } = useAccount();
  const tokenAddress = tokenAddresses[tokenSymbol];

  const { data: allowance, isLoading, refetch } = useReadContract({
    address: tokenAddress,
    abi: ERC20_ABI,
    functionName: 'allowance',
    args: address ? [address, spenderAddress] : undefined,
    query: {
      enabled: !!address,
    },
  });

  return {
    allowance: allowance ? formatUnits(allowance as bigint, 18) : '0',
    rawAllowance: allowance as bigint | undefined,
    isLoading,
    refetch,
  };
}

// Uniswap V3 Adapter Hooks
export function useUniswapV3AddLiquidity() {
  const { writeContract, data: hash, isPending } = useWriteContract();

  const addLiquidity = async (params: {
    token0: `0x${string}`;
    token1: `0x${string}`;
    fee: number;
    amount0: string;
    amount1: string;
    tickLower: number;
    tickUpper: number;
  }) => {
    return writeContract({
      address: contracts.uniswapV3Adapter.address,
      abi: contracts.uniswapV3Adapter.abi,
      functionName: 'addLiquidity',
      args: [
        params.token0,
        params.token1,
        params.fee,
        parseUnits(params.amount0, 18),
        parseUnits(params.amount1, 18),
        params.tickLower,
        params.tickUpper,
      ],
    });
  };

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    addLiquidity,
    isPending,
    isConfirming,
    isSuccess,
    hash,
  };
}

// Aave Adapter Hooks
export function useAaveSupply() {
  const { writeContract, data: hash, isPending } = useWriteContract();

  const supply = async (token: `0x${string}`, amount: string) => {
    return writeContract({
      address: contracts.aaveAdapter.address,
      abi: contracts.aaveAdapter.abi,
      functionName: 'supply',
      args: [token, parseUnits(amount, 18)],
    });
  };

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    supply,
    isPending,
    isConfirming,
    isSuccess,
    hash,
  };
}

export function useAaveWithdraw() {
  const { writeContract, data: hash, isPending } = useWriteContract();

  const withdraw = async (token: `0x${string}`, amount: string) => {
    return writeContract({
      address: contracts.aaveAdapter.address,
      abi: contracts.aaveAdapter.abi,
      functionName: 'withdraw',
      args: [token, parseUnits(amount, 18)],
    });
  };

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    withdraw,
    isPending,
    isConfirming,
    isSuccess,
    hash,
  };
}

// Compound Adapter Hooks
export function useCompoundSupply() {
  const { writeContract, data: hash, isPending } = useWriteContract();

  const supply = async (cToken: `0x${string}`, amount: string) => {
    return writeContract({
      address: contracts.compoundAdapter.address,
      abi: contracts.compoundAdapter.abi,
      functionName: 'supply',
      args: [cToken, parseUnits(amount, 18)],
    });
  };

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    supply,
    isPending,
    isConfirming,
    isSuccess,
    hash,
  };
}

export function useCompoundRedeem() {
  const { writeContract, data: hash, isPending } = useWriteContract();

  const redeem = async (cToken: `0x${string}`, amount: string) => {
    return writeContract({
      address: contracts.compoundAdapter.address,
      abi: contracts.compoundAdapter.abi,
      functionName: 'redeem',
      args: [cToken, parseUnits(amount, 18)],
    });
  };

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    redeem,
    isPending,
    isConfirming,
    isSuccess,
    hash,
  };
}

// Curve Adapter Hooks
export function useCurveAddLiquidity() {
  const { writeContract, data: hash, isPending } = useWriteContract();

  const addLiquidity = async (pool: `0x${string}`, amounts: string[], minMintAmount: string) => {
    const amountsInWei = amounts.map((amt) => parseUnits(amt, 18));
    return writeContract({
      address: contracts.curveAdapter.address,
      abi: contracts.curveAdapter.abi,
      functionName: 'addLiquidity',
      args: [pool, amountsInWei, parseUnits(minMintAmount, 18)],
    });
  };

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    addLiquidity,
    isPending,
    isConfirming,
    isSuccess,
    hash,
  };
}

export function useCurveRemoveLiquidity() {
  const { writeContract, data: hash, isPending } = useWriteContract();

  const removeLiquidity = async (pool: `0x${string}`, lpAmount: string, minAmounts: string[]) => {
    const minAmountsInWei = minAmounts.map((amt) => parseUnits(amt, 18));
    return writeContract({
      address: contracts.curveAdapter.address,
      abi: contracts.curveAdapter.abi,
      functionName: 'removeLiquidity',
      args: [pool, parseUnits(lpAmount, 18), minAmountsInWei],
    });
  };

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    removeLiquidity,
    isPending,
    isConfirming,
    isSuccess,
    hash,
  };
}
