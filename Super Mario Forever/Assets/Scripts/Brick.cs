using System;
using UnityEngine;
using UnityEngine.Events;

public class Brick : MonoBehaviour
{

    [SerializeField]
    private UnityEvent _hit;

    private void OnCollisionEnter2D(Collision2D other)
    {
        var player = other.collider.GetComponent<PlayerMovement>();
        if (player && other.contacts[0].normal.y > 0)
        {
            SFX.Instance.PlaySFX(SFX.Instance.brick);
            _hit?.Invoke();
        }
       
    }
}
