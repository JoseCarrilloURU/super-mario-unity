using Unity.Cinemachine;
using UnityEngine;

public class Enemy : MonoBehaviour
{
    public int damage = 1;
    public PlayerHealth playerHealth;
    public float speed = 6f;
    public GameObject pointA;
    public GameObject pointB;
    private Rigidbody2D rb;
    public Collider2D hideCollider;
    private Transform currentPoint;
    public Animator animator;
    private CinemachineImpulseSource impulseSource;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        currentPoint = pointB.transform;
        transform.localScale = new Vector3(-1, 1, 1);
        impulseSource = GetComponent<CinemachineImpulseSource>();
    }

    void Update()
    {

        Vector2 point = currentPoint.position - transform.position;
        if (currentPoint == pointB.transform)
        {
            rb.linearVelocityX = speed;
        }
        else
        {
            rb.linearVelocityX = -speed;
        }
        if (Vector2.Distance(transform.position, currentPoint.position) < 0.8f)
        {
            if (currentPoint == pointB.transform)
            {
                Flip();
                currentPoint = pointA.transform;
            }
            else
            {
                Flip();
                currentPoint = pointB.transform;
            }
            
        }
    }
    
        private void Flip()
    {
        Vector3 scale = transform.localScale;
        scale.x *= -1;
        transform.localScale = scale;
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(pointA.transform.position, 0.5f);
        Gizmos.DrawWireSphere(pointB.transform.position, 0.5f);
        Gizmos.DrawLine(pointA.transform.position, pointB.transform.position);
    }

    public void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.tag == "Player")
        {
            playerHealth.TakeDamage();
            impulseSource.GenerateImpulse();
        }
    }

    public void Kill()
    {
        SFX.Instance.PlaySFX(SFX.Instance.kill);
        rb.linearVelocityX = 0;
        hideCollider.enabled = false;
        animator.SetBool("GoombaHit", true);
        Destroy(gameObject, animator.GetCurrentAnimatorStateInfo(0).length);
    }
}
