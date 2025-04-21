using UnityEngine;
using UnityEngine.Events;

public class CoinBlock : MonoBehaviour
{
    public int maxJumps = 5; // Public variable to set the number of jumps
    private int currentJumps = 0;
    private bool isActive = true;

    public Spawner spawner;
    public Animator animator;

    [SerializeField]
    private UnityEvent _hit;

    private void OnCollisionEnter2D(Collision2D other)
    {
        var player = other.collider.GetComponent<PlayerMovement>();
        if (isActive && player && other.contacts[0].normal.y > 0)
        {
            currentJumps++;
            if (currentJumps <= maxJumps)
            {
                SFX.Instance.PlaySFX(SFX.Instance.coin);
                spawner.Spawn();
                spawner.Coin();
            }
            if (currentJumps >= maxJumps)
            {
                SFX.Instance.PlaySFX(SFX.Instance.block);
                isActive = false;
                animator.SetBool("NoMoreHits", true);
            }
            _hit?.Invoke();
        }
    }
}