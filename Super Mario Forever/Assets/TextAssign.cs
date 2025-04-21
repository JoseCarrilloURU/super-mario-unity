using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TextAssign : MonoBehaviour
{
    public TextMeshProUGUI coinText;
    public TextMeshProUGUI shardText;
    public TextMeshProUGUI deathText;

    public CoinManager coinManager;
    public PlayerHealth playerHealth;

    void Update()
    {
        UpdateCoinText(coinManager.CoinCount);
        UpdateShardText(coinManager.ShardCount);
        UpdateDeathText(playerHealth.deaths);
    }

    public void UpdateCoinText(int coinCount)
    {
        coinText.text = coinCount.ToString();
    }

    public void UpdateShardText(int shardCount)
    {
        shardText.text = shardCount.ToString();
    }

    public void UpdateDeathText(int deathCount)
    {
        deathText.text = deathCount.ToString();
    }
}