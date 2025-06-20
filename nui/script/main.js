const DEBUG_MODE = 1; // Set this to true to show UI in code editors

document.addEventListener('DOMContentLoaded', () => {
    const body = document.querySelector('body');
    
    if (!DEBUG_MODE) {
        body.style.display = 'none';
    }

    const toggleButton = document.getElementById('toggle-button');
    const statusText = document.getElementById('recycler-status-text');
    let isOn = false;

    toggleButton.addEventListener('click', () => {
        isOn = !isOn;
        if (isOn) {
            toggleButton.innerHTML = '<i class="fas fa-power-off"></i> Turn Off';
            statusText.textContent = 'This Recycler is on. It will continue to recycle items until they run out or it is switched off.';
            // Also send a message to lua that it's on
            fetch(`https://${GetParentResourceName()}/recyclerState`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ state: true })
            });
        } else {
            toggleButton.innerHTML = '<i class="fas fa-power-off"></i> Turn On';
            statusText.textContent = 'The Recycler is currently off.';
            // Also send a message to lua that it's off
            fetch(`https://${GetParentResourceName()}/recyclerState`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ state: false })
            });
        }
    });
});

// Listen for messages from the Lua side
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.type === "setVisible") {
        document.body.style.display = data.status ? 'flex' : 'none';
        if (data.status) {
            fetch(`https://${GetParentResourceName()}/requestFocus`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
        } else {
            fetch(`https://${GetParentResourceName()}/releaseFocus`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
        }
    }
});

// Close UI when Escape is pressed
document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        document.body.style.display = 'none';
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }
});