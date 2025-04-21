using UnityEngine;

public class Shard : MonoBehaviour
{
    public Animator shardAnimator;

    public void Get()
    {
        Collider2D collider = GetComponent<Collider2D>();
        collider.enabled = false;
        SFX.Instance.PlaySFX(SFX.Instance.shard);
        shardAnimator.SetBool("ShardGot", true);
        Destroy(gameObject, shardAnimator.GetCurrentAnimatorStateInfo(0).length);
    }
}
