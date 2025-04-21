using UnityEngine;

public class CoinManager : MonoBehaviour
{
    public int CoinCount;
    public int ShardCount;

    public void IncrementCoinCount()
    {
        CoinCount++;
    }
    public void IncrementShardCount()
    {
        ShardCount++;
    }
}