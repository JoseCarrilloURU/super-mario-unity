using Unity.Cinemachine;
using UnityEngine;

public class Checkpoint : MonoBehaviour
{
    public BoxCollider2D trigger;
    public Transform checkpoint;
    public Animator animator;
    private CinemachineImpulseSource impulseSource;

    void Start()
    {
        impulseSource = GetComponent<CinemachineImpulseSource>();
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            SFX.Instance.PlaySFX(SFX.Instance.checkpoint);
            animator.SetBool("FlagHit", true);
            RespawnController.instance.respawnPoint = checkpoint;
            trigger.enabled = false;
            impulseSource.GenerateImpulse();
        }

    }
}
