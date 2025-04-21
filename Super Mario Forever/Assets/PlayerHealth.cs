using UnityEngine;
using Unity.Cinemachine;
using System.Collections;

public class PlayerHealth : MonoBehaviour
{
    public int MaxHealth = 1;
    public int health;
    public int deaths = 0;
    public Animator animator;
    public Animator transition;
    public CinemachineCamera virtualCamera; // Reference to the Cinemachine virtual camera
    public float zoomDuration = 0.5f; // Duration of the zoom effect
    public float targetOrthographicSize = 5f; // Target orthographic size for the zoom
    private float originalOrthographicSize;
    private CinemachinePositionComposer Composer;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        health = MaxHealth;
        originalOrthographicSize = virtualCamera.Lens.OrthographicSize;
        Composer = virtualCamera.GetComponent<CinemachinePositionComposer>();

    }

    public void TakeDamage()
    {
        SFX.Instance.PlaySFX(SFX.Instance.hit);
        transition.SetBool("Killed", true);
        animator.SetBool("Hit", true);
        StartCoroutine(ZoomIn());
        StartCoroutine(Reset());
        StartCoroutine(Cam());
        deaths++;
    }

    private IEnumerator Reset()
    {
        yield return new WaitForSeconds(0.8f);
        animator.SetBool("Hit", false);
        virtualCamera.Lens.OrthographicSize = originalOrthographicSize;
        gameObject.transform.position = RespawnController.instance.respawnPoint.position;
        Composer.Damping = new Vector3(1, 1, 1);
        Composer.Lookahead.Enabled = true;
    }

    private IEnumerator Cam()
    {
        yield return new WaitForSeconds(2f);
        transition.SetBool("Killed", false);
    }
    private IEnumerator ZoomIn()
    {
        float elapsedTime = 0f;
        float startOrthographicSize = virtualCamera.Lens.OrthographicSize;

        Composer.Lookahead.Enabled = false;
        Composer.Damping = Vector3.zero;

        while (elapsedTime < zoomDuration)
        {
            virtualCamera.Lens.OrthographicSize = Mathf.Lerp(startOrthographicSize, targetOrthographicSize, elapsedTime / zoomDuration);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        virtualCamera.Lens.OrthographicSize = targetOrthographicSize;
    }
}
