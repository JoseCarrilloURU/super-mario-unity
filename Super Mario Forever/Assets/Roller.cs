using Unity.Cinemachine;
using UnityEngine;

public class Roller : MonoBehaviour
{
    public int damage = 1;
    public PlayerHealth playerHealth;
    public float speed = 6f;
    public GameObject pointA;
    public GameObject pointB;
    private Rigidbody2D rb;
    private Transform currentPoint;
    private float rotationSpeed;
    private CinemachineImpulseSource impulseSource;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        currentPoint = pointB.transform;
        transform.localScale = new Vector3(1, 1, 1);
        rotationSpeed = speed * 35f;
        rotationSpeed = -rotationSpeed;
        impulseSource = GetComponent<CinemachineImpulseSource>();
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(0, 0, rotationSpeed * Time.deltaTime);

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
        rotationSpeed *= -1;
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
}
