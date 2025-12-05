let timerInterval;
let timeLeft = 15 * 60;
let isRunning = false;

function initFokusModal() {
  // Supprime tous les anciens event listeners
  const oldBtns = document.querySelectorAll('.fokus-btn');
  oldBtns.forEach(btn => {
    const newBtn = btn.cloneNode(true);
    btn.parentNode.replaceChild(newBtn, btn);
  });

  // Récupère le premier bouton FOKUS existant
  const fokusBtn = document.querySelector('.fokus-btn');
  const fokusModalEl = document.getElementById('fokusModal');
  const taskNameEl = document.getElementById('taskName');
  const timerDisplay = document.getElementById('timer');
  const startBtn = document.getElementById('startBtn');
  const pauseBtn = document.getElementById('pauseBtn');
  const stopBtn = document.getElementById('stopBtn');

  if (!fokusBtn) return;

  // Met à jour le nom de la tâche
  const taskName = fokusBtn.dataset.taskName || 'Tâche';
  taskNameEl.textContent = taskName;

  // Reset timer
  function resetTimer() {
    if (timerInterval) clearInterval(timerInterval);
    isRunning = false;
    timeLeft = 15 * 60;
    const minutes = Math.floor(timeLeft / 60);
    const seconds = timeLeft % 60;
    timerDisplay.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    startBtn.style.display = 'inline-block';
    pauseBtn.style.display = 'none';
  }

  // Event listeners pour les boutons du timer
  startBtn.onclick = function() {
    if (!isRunning) {
      isRunning = true;
      startBtn.style.display = 'none';
      pauseBtn.style.display = 'inline-block';
      timerInterval = setInterval(() => {
        timeLeft--;
        const minutes = Math.floor(timeLeft / 60);
        const seconds = timeLeft % 60;
        timerDisplay.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
        if (timeLeft <= 0) {
          clearInterval(timerInterval);
          isRunning = false;
          startBtn.style.display = 'inline-block';
          pauseBtn.style.display = 'none';
          alert('Session FOKUS terminée ! 🎉');
        }
      }, 1000);
    }
  };

  pauseBtn.onclick = function() {
    if (isRunning) {
      isRunning = false;
      clearInterval(timerInterval);
      startBtn.style.display = 'inline-block';
      pauseBtn.style.display = 'none';
    }
  };

  stopBtn.onclick = function() {
    resetTimer();
    const modal = bootstrap.Modal.getInstance(fokusModalEl);
    if (modal) modal.hide();
  };
}

// Initialise au chargement et observe les changements DOM
document.addEventListener("DOMContentLoaded", initFokusModal);

// Réinitialise après chaque changement de tâches (AJAX/turbo)
document.addEventListener('turbo:load', initFokusModal);
document.addEventListener('turbo:render', initFokusModal);

// MutationObserver pour détecter les nouveaux boutons créés dynamiquement
const observer = new MutationObserver(() => {
  const fokusBtn = document.querySelector('.fokus-btn');
  if (fokusBtn && !fokusBtn.hasAttribute('data-fokus-initialized')) {
    fokusBtn.setAttribute('data-fokus-initialized', 'true');
    initFokusModal();
  }
});
observer.observe(document.body, { childList: true, subtree: true });
