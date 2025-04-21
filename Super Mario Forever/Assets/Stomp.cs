using UnityEngine;

public class Stomp : MonoBehaviour
{
    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.tag == "Goomba")
        {
            Destroy(collision.gameObject);
        }
    }
}
