using UnityEngine;

public class RespawnController : MonoBehaviour
{
    public static RespawnController instance;
    public PlayerHealth playerHealth;
    public Transform respawnPoint;

    private void Awake()
    {
        instance = this;
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag("Player"))
        {
            playerHealth.TakeDamage();
        }
    }
}
