type PlausibleEventProps = Record<string, unknown>;

const trackPlausible = (eventName: string, props: PlausibleEventProps = {}) => {
	if (typeof window !== 'undefined' && typeof window.plausible === 'function') {
		window.plausible(eventName, { props });
	}
};

const initProjectTracking = () => {
	document.querySelectorAll<HTMLAnchorElement>('[data-plausible-project]').forEach((link) => {
		const projectName = link.dataset.plausibleProject ?? 'Project';
		link.addEventListener('click', () => trackPlausible('Project Card Click', { project: projectName }));
	});
};

const initScheduleTracking = () => {
	document.querySelectorAll<HTMLAnchorElement>('[data-plausible-event="Schedule Call"]').forEach((link) => {
		link.addEventListener('click', () => trackPlausible('Schedule Call'));
	});
};

const lockButtonWidth = (button: HTMLButtonElement) => {
	if (!button.dataset.buttonWidth) {
		const { width } = button.getBoundingClientRect();
		button.style.minWidth = `${width}px`;
		button.dataset.buttonWidth = `${width}px`;
	}
};

const initCopyButtons = () => {
	document.querySelectorAll<HTMLButtonElement>('[data-copy-email]').forEach((button) => {
		const label = button.querySelector<HTMLElement>('[data-copy-email-label]');
		const emailUser = button.dataset.emailUser ?? '';
		const emailDomain = button.dataset.emailDomain ?? '';
		const emailTag = button.dataset.emailTag ?? '';
		const displayEmail = emailUser && emailDomain ? `${emailUser}@${emailDomain}` : label?.textContent ?? '';
		if (label && displayEmail) {
			label.textContent = displayEmail;
		}
		lockButtonWidth(button);
		button.addEventListener('click', async () => {
			if (!navigator.clipboard || !label) return;
			const trackedEmail = emailUser && emailDomain
				? `${emailUser}${emailTag ? `+${emailTag}` : ''}@${emailDomain}`
				: label.textContent ?? '';
			try {
				await navigator.clipboard.writeText(trackedEmail);
				const originalText = label.textContent ?? '';
				label.dataset.originalText = originalText;
				label.textContent = 'Copied';
				button.classList.add('is-copied');
				trackPlausible('Email Copied', { location: 'Next steps', email: displayEmail });
				const timeout = window.setTimeout(() => {
					label.textContent = label.dataset.originalText ?? originalText;
					button.classList.remove('is-copied');
					window.clearTimeout(timeout);
				}, 1400);
			} catch (err) {
				console.error('Clipboard copy failed', err);
			}
		});
	});
};

const init = () => {
	initProjectTracking();
	initScheduleTracking();
	initCopyButtons();
};

if (document.readyState === 'loading') {
	document.addEventListener('DOMContentLoaded', init, { once: true });
} else {
	init();
}

export {};
