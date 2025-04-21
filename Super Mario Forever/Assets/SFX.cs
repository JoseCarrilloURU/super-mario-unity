using UnityEngine;

public class SFX : MonoBehaviour
{
    public static SFX Instance { get; private set; }

    [SerializeField] AudioSource SFXSource;
    public AudioClip jump;
    public AudioClip coin;
    public AudioClip shard;
    public AudioClip hit;
    public AudioClip brick;
    public AudioClip block;
    public AudioClip checkpoint;
    public AudioClip kill;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void PlaySFX(AudioClip clip)
    {
        SFXSource.PlayOneShot(clip);
    }
}