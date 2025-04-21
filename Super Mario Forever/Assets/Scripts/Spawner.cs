using UnityEngine;

public class Spawner : MonoBehaviour
{

    public CoinManager CoinManager;
    [SerializeField] private GameObject prefabToSpawn;

    public void Spawn()
    {
        Instantiate(prefabToSpawn, transform.position, Quaternion.identity);
    }

    public void Coin()
    {
        CoinManager.CoinCount++;
    }

}
