const DEBUG_MODE = 1; // Set this to true to show UI in code editors

const sampleItems = [
    { name: "Metal Scraps", image: "img/acetone.png", amount: 15 },
    { name: "Wood", image: "img/adderall.png", amount: 8 },
    { name: "Plastic", image: "img/advancedkit.png", amount: 3 }
];

const sampleOutputItems = [
    { name: "Recycled Metal", image: "img/advancedlockpick.png", amount: 5 },
];

document.addEventListener('DOMContentLoaded', () => {
    const body = document.querySelector('body');
    
    if (!DEBUG_MODE) {
        body.style.display = 'none';
    }

    // Load sample items if in debug mode
    if (DEBUG_MODE) {
        loadSampleItems();
    }

    const toggleButton = document.getElementById('toggle-button');
    const statusText = document.getElementById('recycler-status-text');
    let isOn = false;

    toggleButton.addEventListener('click', () => {
        isOn = !isOn;
        toggleButton.classList.toggle('on', isOn);
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

function loadSampleItems() {
    const inputGrid = document.querySelector('.inventory-section .item-grid');
    const outputGrid = document.querySelectorAll('.inventory-section .item-grid')[1];
    const inputSlots = inputGrid.querySelectorAll('.item-slot');
    const outputSlots = outputGrid.querySelectorAll('.item-slot');
    
    // Add sample items to input slots
    sampleItems.forEach((item, index) => {
        if (index < inputSlots.length) {
            const img = document.createElement('img');
            img.src = item.image;
            img.alt = item.name;
            img.title = item.name;
            inputSlots[index].appendChild(img);
            
            const amountDiv = document.createElement('div');
            amountDiv.className = 'amount';
            amountDiv.textContent = item.amount;
            inputSlots[index].appendChild(amountDiv);
            
            // Add tooltip functionality
            addTooltip(inputSlots[index], item.name, item.amount);
        }
    });
    
    // Add sample items to output slots
    sampleOutputItems.forEach((item, index) => {
        if (index < outputSlots.length) {
            const img = document.createElement('img');
            img.src = item.image;
            img.alt = item.name;
            img.title = item.name;
            outputSlots[index].appendChild(img);
            
            const amountDiv = document.createElement('div');
            amountDiv.className = 'amount';
            amountDiv.textContent = item.amount;
            outputSlots[index].appendChild(amountDiv);
            
            // Add tooltip functionality
            addTooltip(outputSlots[index], item.name, item.amount);
        }
    });
}

function addTooltip(element, itemName, amount) {
    let tooltip = null;
    
    const showTooltip = (e) => {
        // Remove any existing tooltip first
        removeTooltip();
        
        tooltip = document.createElement('div');
        tooltip.className = 'tooltip';
        tooltip.textContent = `${itemName} (${amount})`;
        document.body.appendChild(tooltip);
        
        const rect = element.getBoundingClientRect();
        tooltip.style.left = (rect.left + rect.width / 2 - tooltip.offsetWidth / 2) + 'px';
        tooltip.style.top = (rect.top - tooltip.offsetHeight - 8) + 'px';
        
        // Use requestAnimationFrame for smoother animation
        requestAnimationFrame(() => {
            if (tooltip) {
                tooltip.classList.add('show');
            }
        });
    };
    
    const removeTooltip = () => {
        if (tooltip) {
            tooltip.classList.remove('show');
            setTimeout(() => {
                if (tooltip && tooltip.parentNode) {
                    document.body.removeChild(tooltip);
                }
                tooltip = null;
            }, 200);
        }
    };
    
    element.addEventListener('mouseenter', showTooltip);
    element.addEventListener('mouseleave', removeTooltip);
    
    // Add additional cleanup for when mouse moves away quickly
    element.addEventListener('mousemove', (e) => {
        const rect = element.getBoundingClientRect();
        const isInside = e.clientX >= rect.left && e.clientX <= rect.right && 
                        e.clientY >= rect.top && e.clientY <= rect.bottom;
        if (!isInside && tooltip) {
            removeTooltip();
        }
    });
}

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