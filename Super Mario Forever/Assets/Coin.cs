using UnityEngine;

public class Coin : MonoBehaviour
{
    public Animator coinAnimator;

    public void Get()
    {
        Collider2D collider = GetComponent<Collider2D>();
        collider.enabled = false;
        SFX.Instance.PlaySFX(SFX.Instance.coin);
        coinAnimator.SetBool("CoinGot", true);
        Destroy(gameObject, coinAnimator.GetCurrentAnimatorStateInfo(0).length);
    }
}