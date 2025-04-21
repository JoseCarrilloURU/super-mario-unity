using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public CharacterController2D controller;
    public CoinManager CoinManager;
    public float runSpeed = 40f;
    public Animator animator;

    private float horizontalMove = 0f;
    private bool jump = false;
    private bool crouch = false;
    private bool isJumping = false; // Track if the player is currently in a jump

    [Header("Jump Buffer Settings")]
    [SerializeField] private float jumpBufferTime = 0.2f; // 200ms buffer
    private float jumpBufferCounter = 0f;

    [Header("Coyote Time Settings")]
    [SerializeField] private float coyoteTime = 0.1f; // Time the player can jump after leaving the ground
    private float coyoteTimeCounter = 0f;

    void Update()
    {
        // Handle horizontal movement
        horizontalMove = Input.GetAxisRaw("Horizontal") * runSpeed;
        animator.SetFloat("Speed", Mathf.Abs(horizontalMove));

        // Handle jump input
        if (Input.GetButtonDown("Jump"))
        {
            jumpBufferCounter = jumpBufferTime; // Start the jump buffer timer
        }

        // Update jump and fall animations
        if (!controller.m_Grounded && controller.m_Rigidbody2D.linearVelocity.y < 0)
        {
            animator.SetBool("IsFalling", true);
        }
        else
        {
            animator.SetBool("IsFalling", false);
        }

        //Coyote Time
        if (controller.m_Grounded)
        {
            coyoteTimeCounter = coyoteTime;
        }
        else
        {
            coyoteTimeCounter -= Time.deltaTime;
        }
    }

    public void onLanding()
    {
        animator.SetBool("IsJumping", false);
        jump = false;
        isJumping = false; // Reset the isJumping flag on landing
    }

    public void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.CompareTag("Coin"))
        {
            var coin = other.gameObject.GetComponent<Coin>();
            coin.Get();
            CoinManager.IncrementCoinCount();
        }
        if (other.gameObject.CompareTag("Shard"))
        {
            var shard = other.gameObject.GetComponent<Shard>();
            shard.Get();
            CoinManager.IncrementShardCount();
        }

        if (other.gameObject.CompareTag("Goomba"))
        {
            var enemy = other.gameObject.GetComponent<Enemy>();
            enemy.Kill();
        }
    }

    void FixedUpdate()
    {
        // Decrease the jump buffer counter over time
        if (jumpBufferCounter > 0)
        {
            jumpBufferCounter -= Time.fixedDeltaTime;
        }

        // Check if the player should jump
        if (jumpBufferCounter > 0)
        {
            //If the player is grounded or in coyote time and not jumping
            if ((controller.m_Grounded || coyoteTimeCounter > 0f) && !isJumping)
            {
                animator.SetBool("IsJumping", true);
                jump = true; // Allow the jump
                isJumping = true; // Set the flag to true
                jumpBufferCounter = 0; // Reset the buffer
                coyoteTimeCounter = 0; //Reset the coyote time
            }
            //If the player is in the air and jumping
            else if (!controller.m_Grounded && isJumping)
            {
                jumpBufferCounter = 0;
            }
        }
        else
        {
            jump = false;
        }

        // Pass movement and jump to the controller
        controller.Move(horizontalMove * Time.fixedDeltaTime, crouch, jump);
    }
}
