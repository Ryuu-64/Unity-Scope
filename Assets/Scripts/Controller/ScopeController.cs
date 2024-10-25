using UnityEngine;

namespace Controller
{
    public class ScopeController : MonoBehaviour
    {
        [SerializeField] private float magnification = 1;
        private Camera _mainCamera;
        private Camera _scopeCamera;

        private void Awake()
        {
            _mainCamera = Camera.main;
            _scopeCamera = GetComponentInChildren<Camera>();
        }

        private void FixedUpdate()
        {
            float mainFOV = _mainCamera.fieldOfView;
            float scopeFOV = CalcScopeFOV(mainFOV, magnification);
            _scopeCamera.fieldOfView = scopeFOV;
        }

        private float CalcScopeFOV(float mainCameraFOV, float magnification)
        {
            float mainCameraFieldOfViewDiameter = 2 * Mathf.Tan(mainCameraFOV / 2f * Mathf.Deg2Rad);
            float scopeFieldOfViewDiameter = mainCameraFieldOfViewDiameter / magnification;
            float scopeFOV = Mathf.Atan(scopeFieldOfViewDiameter / 2) * 2 * Mathf.Rad2Deg;
            return scopeFOV;
        }
    }
}